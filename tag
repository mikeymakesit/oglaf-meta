#!/usr/bin/env python3

import argparse
import json


json_archive    = 'archive.json'
json_tags       = 'tags.json'
debug           = False


parser = argparse.ArgumentParser(description='Oglaf comic tag manager')
parser.add_argument('-s', action='store_true',
    help='Search - Find tags in strips [DEFAULT]')
parser.add_argument('-a', action='store_true',
    help='Add - Add tags to strips')
parser.add_argument('-d', action='store_true',
    help='Delete - Delete tags from strips')
parser.add_argument('-l', action='store_true',
    help='List - List all tags')
parser.add_argument('-af', metavar='filename', action='store',
    help='Archive file - Provide a custom JSON archive filename instead of the default "' + json_archive + '"')
parser.add_argument('-tf', metavar='filename', action='store',
    help='Tag file - Provide a custom JSON tag set instead of the default "' + json_tags + '"')
parser.add_argument('-t', '-tag', action='append', metavar='word',
    help='Tag - Keyword relevant to your activity, can be specified more than once')
parser.add_argument('-title', action='append',
    help='Title - The title of a comic related to your activity, can be specified more than once')
args = parser.parse_args()


if args.af is not None:
    json_archive = args.af
if args.tf is not None:
    json_tags = args.tf
if debug:
    print('Archive: {}\nTagset: {}'.format(json_archive, json_tags))


def read_json(f):
    ''' Read a file and return the JSON-parsed contents. '''
    with open(f, 'r') as infile:
        fd = infile.read()
    d = json.loads(fd)
    return d


def write_json(f, d):
    ''' Write some JSON out to a file. '''
    with open(f, 'w') as outfile:
        json.dump(d, outfile)


ad = read_json(json_archive)
td = read_json(json_tags)


if args.a or args.d:
    # ADD OR DELETE TAGS
    changed = 0
    if not args.title:
        print("You need to specify which titles to modify.")
        quit()
    for title in args.title:
        # Match the documented title's case
        known_title = False
        for t in ad.keys():
            if t.lower() == title.lower():
                title = t
                known_title = True
                break
        if not known_title:
            print("Can't find title '{}'".format(title))
            continue

        for tag in args.t:
            change = True
            ltag = tag.lower()
            if title in td.keys():
                for current_tag in td[title]:
                    if ltag == current_tag.lower() and args.a:
                        print("Tag '{}' already applied to '{}'".format(current_tag, title))
                        change = False
                if args.d and not any(thistag.lower() == ltag for thistag in td[title]):
                    print("Tag '{}' is not applied to '{}'".format(tag, title))
                    change = False

            if change and args.a:
                if title not in td.keys():
                    td[title] = list()
                td[title].append(tag)
                changed += 1
            elif change and args.d:
                for current_tag in td[title]:
                    if ltag == current_tag.lower():
                        td[title].remove(current_tag)
                        changed += 1

    if changed > 0:
        write_json(json_tags, td)
        print("Made {} changes to the tag tracker".format(changed))

else:
    # SEARCH TAGS
    hits = dict()
    if args.t:
        for tag in args.t:
            ltag = tag.lower()
            for k, v in td.items():
                if any(s.lower() == ltag for s in v):
                    if k not in hits:
                        hits[k] = list()
                    hits[k].append(tag)
        if len(hits) > 0:
            for h in hits:
                print("{} ({})".format(h, ', '.join(hits[h])))
        else:
            print("No matches.")

    elif args.l:
        tags = set()
        for k, v in td.items():
            for t in v:
                if args.title and not any(lt == k.lower() for lt in args.title):
                    continue
                tags.add(t)

        print("Tags:\n{}".format('\n'.join(sorted(tags))))

