#!/usr/bin/env python3

import json


class TomeOfKnowledge:
    ''' Easily manipulate and interact with comic strip data. '''

    PROTOHOST    = 'https://www.oglaf.com'
    ARCHIVE_URL  = PROTOHOST + '/archive/'
    JSON_ARCHIVE = 'archive.json'
    JSON_TAGS    = 'tags.json'


    def __init__(self, archive_file=JSON_ARCHIVE, tags_file=JSON_TAGS):
        ''' Initialize '''
        self.titles = dict()
        self.urls = dict()
        self.tags = dict()
        self.lctitles = dict()
        self.lctags = dict()

        self.files = dict()
        self.files['archive'] = archive_file
        self.files['tags'] = tags_file
        self.load_archive()
        self.load_tags()


    # Import JSON from file and raise exception on error
    def get_json(self, f):
        ''' Load JSON from file and return the object '''
        try:
            with open(f, 'r') as infile:
                fd = infile.read()
        except FileNotFoundError:
            raise Exception("Your specified JSON file is not found or readable: {}".format(f))
        return json.loads(fd)


    # Build a 2-way structure like:
    #   self.titles['Cumsprite']['urls'] = [ 'https://blah', 'https://blah/2' ]
    #   self.urls['https://blah'] = 'Cumsprite'
    #
    def load_archive(self):
        ''' Load an archive of comic strip data '''
        j = self.get_json(self.files['archive'])
        self.titles.update(j)
        for title in j.keys():
            self.titles[title]['tags'] = list()
            self.lctitles[title.lower()] = title
            for url in j[title]['urls']:
                self.urls[url] = title


    # Build a 2-way structure like:
    #   self.titles['Cumsprite']['tags'] = [ 'Ivan', 'Mistress' ]
    #   self.tags['Ivan'] = [ 'Cumsprite' ]
    #   self.tags['Mistress'] = [ 'Cumsprite' ]
    #
    def load_tags(self):
        ''' Load an archive of comic strip tag data '''
        j = self.get_json(self.files['tags'])
        for title in j.keys():
            self.titles[title]['tags'] = j[title]
            for tag in j[title]:
                self.lctags[tag.lower()] = tag
                if tag not in self.tags:
                    self.tags[tag] = list()
                self.tags[tag].append(title)


    def save_tags(self):
        ''' Write out a tag-set to file '''
        out = dict()
        for title in self.titles.keys():
            if 'tags' in self.titles[title].keys():
                out[title] = self.titles[title]['tags']
            else:
                out[title] = list()

        with open(self.files['tags'], 'w') as outfile:
            json.dump(out, outfile, indent=2)


if __name__ == '__main__':
    print("Don't wank me.  I'm telling!!")
