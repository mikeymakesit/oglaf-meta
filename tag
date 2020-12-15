#!/usr/bin/env python3

import argparse
import json
from oglaf import TomeOfKnowledge


json_archive    = 'archive.json'
json_tags       = 'tags.json'


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
    help='Archive file - Provide a custom JSON archive file instead of the default "' + json_archive + '"')
parser.add_argument('-tf', metavar='filename', action='store',
    help='Tag file - Provide a custom JSON tag file instead of the default "' + json_tags + '"')
parser.add_argument('-t', '-tag', action='append', metavar='word',
    help='Tag - Keyword relevant to your activity, can be specified more than once')
parser.add_argument('-title', action='append',
    help='Title - The title of a comic related to your activity, can be specified more than once')
parser.add_argument('-url', action='append',
    help='The URL of a comic related to your activity, can be specified more than once')
args = parser.parse_args()

if args.af:
    json_archive = args.af
if args.tf:
    json_tags = args.tf


tome = TomeOfKnowledge( archive_file = json_archive, tags_file = json_tags )


def urls2titles():
    ''' Given a TomeOfKnowledge return a title for a given list of URLs '''
    if not args.title:
        args.title = list()
    for url in args.url:
        found = False
        for tome_url in tome.urls.keys():
            if url in tome_url:
                found = True
                args.title.append(tome.urls[tome_url])
                break
        if not found:
            print("No strip found related to URL: {}".format(url))
    if len(args.title) == 0:
        print("Couldn't find any titles for your URLs, so quitting.  Bye.")
        quit()



# ADD OR DELETE TAGS
if args.a or args.d:
    changed = 0
    if not args.title and not args.url:
        print("You need to specify at least 1 title or URL to modify tags for.")
        quit()

    # Get title(s) from supplied URL(s)
    if args.url:
        urls2titles()

    # Iterate over each title specified (including titles retrieved from URLs)
    for title in args.title:
        # Match the documented title's case
        known_title = False
        ltitle = title.lower()
        if ltitle in tome.lctitles.keys():
            title = tome.lctitles[ltitle]
            known_title = True
        if not known_title:
            print("Can't find title '{}'".format(title))
            continue

        # Process each tag for each title
        for tag in args.t:
            change = True
            ltag = tag.lower()
            if ltag in tome.lctags.keys():
                # Prefer the case of existing tags so we don't end up with separate
                # tags like: Tits, TITS, tIts
                tag = tome.lctags[ltag]
                if args.a and title in tome.tags[tag]:
                    print("Tag '{}' already applied to '{}'".format(tag, title))
                    change = False
            else:
                if args.d:
                    print("Tag '{}' is not applied to '{}'".format(tag, title))
                    change = False

            # Actually make the addition that was requested and validated
            if change and args.a:
                if tag not in tome.tags.keys():
                    tome.tags[tag] = list()
                tome.tags[tag].append(title)
                tome.titles[title]['tags'].append(tag)
                changed += 1

            # Actually make the deletion that was requested and validated
            elif change and args.d:
                tome.tags[tag].remove(title)
                tome.titles[title]['tags'].remove(tag)
                changed += 1

    # Save data back to files
    if changed > 0:
        tome.save_tags()
        print("{} changes complete".format(changed))
    quit()


# Search by tag(s)
# Will use logical OR if multiple tags specified by user
if args.t:
    hits = dict()
    for tag in args.t:
        ltag = tag.lower()
        if ltag in tome.lctags:
            proper_tag = tome.lctags[ltag]
            for title in tome.tags[proper_tag]:
                if title not in hits.keys():
                    hits[title] = list()
                hits[title].append(proper_tag)

    if len(hits) > 0:
        for title in hits.keys():
            print("{} ({})".format(title, ', '.join(sorted(hits[title]))))
    else:
        print("No matches.")


# Dump tags by title or URL
elif args.title or args.url:
    # Get title(s) from supplied URL(s)
    if args.url:
        urls2titles()

    for thistitle in args.title:
        print(thistitle)
        found = False
        lthistitle = thistitle.lower()
        if lthistitle in tome.lctitles.keys():
            found = True
            for tag in sorted(tome.titles[tome.lctitles[lthistitle]]['tags']):
                print('\t' + tag)
        if not found:
            print("\tSorry, can't find '{}' in tag set.".format(thistitle))


# Dump tags
elif args.l:
    print('\n'.join(sorted(tome.tags.keys())))


else:
    parser.print_help()
