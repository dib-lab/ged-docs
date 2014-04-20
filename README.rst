GED-DOCS Pages
==============

About
-----

This repo serves as a holding area for information on bioinformatics tools commonly used by the lab. These pages are poweruser oriented; they are not meant to be exhaustive tutorials, but rather a way for us to share our use cases and parameters internally. The preferred format for each page is as follows:

* tool name and version
* link to tool webpage and/or paper
* in general, what does it do?
* what is its availability -- is it on the hpcc or athyra?
* your common use case (and also, who are you?)
* parameters, and short justification for parameters
* common pitfalls, if any (for example, outputs ten files, which one matters?)
* hand-wavey performance estimate, if necessary (if you really grok the tool, use big-O notation)
* example shell use

Wiki
----

This space is divided between the repo and the wiki. The wiki is preferred; after you've put up a page, if you'd like, just copy the text into a file, check it into the repo, and add it to the ``Makefile``. Running ``make`` will put together all the pages into one pdf; this way, we have things in a better archival format as well.

Dependencies
------------

For the wiki, none; just use that built-in editor.

For the repo, you'll need pandoc and a latex install.
