# sql\_tagger

[![Build Status](https://travis-ci.org/SlideShareInc/sql_tagger.svg?branch=master)](https://travis-ci.org/SlideShareInc/sql_tagger)

sql\_tagger is a gem that inserts comments into SQL queries. These comments
include a string from `Kernel#caller` that (hopefully) reveals what Ruby code
was responsible for performing the query.

To use this, just require the appropriate file. For example, to use this with
the `mysql2` gem, write `require 'sql_tagger/mysql2'` instead of `require
'mysql2'`.

Before:

    SELECT 1

After:

    /* program.rb:25:in `some_method' */ SELECT 1
