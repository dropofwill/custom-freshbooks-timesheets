# custom-freshbooks-timesheets

A simple ruby command line tool that turns time data from Freshbooks renders a slim template and turns that into a pdf.

Still a work in progress, still has a lot of hardcoded info at the moment. I plan on packaging this up as a gem at some point when I get some free time.

Currently you have to define your name and export path in the `generate_timesehet.rb` file and you'll need to add your own info to the `timesheet.html.slim` file. Then run it with whatever to and from timestamps you need, e.g.

~~~
ruby generate_timesheet.rb 2015-02-02 2015-02-15
~~~
