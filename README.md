# Oglaf Meta

The purpose of this project is to identify past strips from the __[Oglaf](https://oglaf.com/)__ webcomic,
with the ability to build reading guides based on tags applied to strips.
I've enjoyed reading Oglaf over the years, and this is my way of getting back
to the threads I love.

The project comes with code and a curated assemblage of information:
1. __rguide__: Generate a reading guide based on tags or a story arc
2. __ogmeta__: Manage metadata - get new strip info from the website, add/delete tags and story arcs, search metadata
5. __meta.json__: Local metadata about published strips
6. __characters.png__: A depiction of many recurring characters, with names, based on the
original work of [/u/Fraxinopolis](https://old.reddit.com/u/Fraxinopolis) as posted [in this thread](https://old.reddit.com/r/oglaf/comments/ijbsb9/chart_of_recurring_characters/)

Feel free to submit pull requests if you find errors or discrepancies in this 
code or the tagging.  Tagging is totally subjective but I've tried to be straightforward.

## Setup
To set up your environment to run this project:
``` shell
python3 -m venv venv
. venv/bin/activate
pip3 install --upgrade pip
pip3 install -r requirements.txt
```

## Review the help text
See brief help text by running:
``` shell
./rguide -h
```
or:
``` shell
./ogmeta -h
```

The tools put in a small effort to save you from yourself but, really, the onus is
on you not to shoot yourself in the foot.  I recommend backing up your JSON 
file occasionally just in case you play around and want to revert back.


## Build a reading guide
The reading guide builder generates the titles and URLs for strips that contain __all__
the specified tags or the provided story arc.  The guide is presented in 
publication-date order.

Imagine you want to re-read all the great strips starring Ivan:
``` shell
./rguide -tag ivan
```

or maybe you want to read the "Fun Cult" story arc:
``` shell
./rguide -arc "Fun Cult"
```

Now imagine you only want to re-read the strips with both Ivan _and_ Mistress:
``` shell
./rguide -tag ivan -tag mistress
```


## Working with tags
Please note that when searching, the tags you specify are _not_ case sensitive.  However
when you add tags, they're added exactly as you type them.  Consider checking the tag set
before you add any and try to be consistent with the capitalization style.

Also note if you're using tags with spaces or other characters your system may
interpret as command-line special characters, wrap those tags in quotes!

Search for a tag:
``` shell
./ogmeta -s -tag ivan
```

Search for a tag with spaces in its name:
``` shell
./ogmeta -s -tag "the golden hind"
```

Add a tag to one or more strips by specifying the strip's title or one of 
its page URLs:
``` shell
./ogmeta -a -url https://www.oglaf.com/cumsprite/ -tag Mistress -tag Ivan
./ogmeta -a -title cumsprite -t Mistress -t Ivan
```

Dump a list of all tags:
``` shell
./ogmeta -l tags
```

Dump a list of all titles:
``` shell
./ogmeta -l titles
```

## Updating Archive Data
If you want to update your local metadata with new strip data, that's easy:
```shell
./ogmeta -fetchnew
```

## Reference
I found the following sites helpful while working on this project:
- https://www.oglaf.com/archive/
- https://old.reddit.com/r/oglaf
- https://tvtropes.org/pmwiki/pmwiki.php/Characters/Oglaf

