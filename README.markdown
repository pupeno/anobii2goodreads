Copyright 2011 J. Pablo Fernández <pupeno@pupeno.com> (http://pupeno.com)

This program converts exported data from aNobii into GoodReads.

You have to call it like this:

    anobii2goodreads.rb anobiishelf.csv anobiiwishlist.csv goodreads.csv

Known problems
--------------

* Multiline reviews may cause problems in some cases, causing the book not to be imported.

* Dates from aNobii that contain year or year and month (but not date) are lost.