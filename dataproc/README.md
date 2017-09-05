# Software Engineering Interview Response

## SETUP

## Ruby version
This software runs on ruby 2.4.1

Install ruby using `rbenv` in a `bash` prompt:

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile
git clone https://github.com/rbenv/ruby-build.git
~/.rbenv/plugins/ruby-build
rbenv install 2.4.1
rbenv global 2.4.1
rbenv rehash
```
NOTE: replace `.bash_profile` with `.bashrc` or other appropriate file for your shell


*Troubleshooting*
If ruby-build could not find a ruby version of 2.2.2 or higher,
you will need to update your ruby-build.
If ruby-build was installed via homebrew on Mac, it will be in `/usr/local/Cellar/ruby-build`.
I recommend removing that directory and re-installing ruby-build as an rbenv plugin. Instructions to install as rbenv plugin and update are here:
https://github.com/rbenv/ruby-build#installation

Once ruby-build is updated, you should now see at least 2.2.2

`rbenv install -l`

Now you can install ruby 2.2.2 or greater

`rbenv install 2.4.1`

# Running the Software
Once ruby 2.4.1 is installed, change to the directory containing the code.

```bash
bash
rbenv local
```
The above should say 2.4.1. If not, then run

```bash
rbenv local 2.4.1
rbenv rehash
```

And you can run the program like this:
```bash
ruby normalize.rb path/to/dirty_input.csv path/to/normalized_output.csv
```
where dirty_input.csv is the file you want to normalize and 
normalized_output.csv is the name of the normalized version
of that file. normalized_output.csv should have a path in which
you have permission to create files.



## The problem: CSV normalization

Please write a tool that reads a CSV formatted file on `stdin` and
emits a normalized CSV formatted file on `stdout`. Normalized, in this
case, means:

* The entire CSV is in the UTF-8 character set.
* The Timestamp column should be formatted in ISO-8601 format.
* The Timestamp column should be assumed to be in US/Pacific time;
  please convert it to US/Eastern.
* All ZIP codes should be formatted as 5 digits. If there are less
  than 5 digits, assume 0 as the prefix.
* All name columns should be converted to uppercase. There will be
  non-English names.
* The Address column should be passed through as is, except for
  Unicode validation. Please note that there are commas in the Address
  field, your CSV parsing will need to take that into account.
* The columns `FooDuration` and `BarDuration` are in HH:MM:SS.MS
  format; please convert them to a floating point seconds format.
* The column "TotalDuration" is filled with garbage data. For each
  row, please replace the value of TotalDuration with the sum of
  FooDuration and BarDuration.
* The column "Notes" is free form text input by end-users; please do
  not perform any transformations on this column. If there are invalid
  UTF-8 characters, please replace them with the Unicode Replacement
  Character.

You can assume that the input document is in UTF-8 and that any times
that are missing timezone information are in US/Pacific. If a
character is invalid, please replace it with the Unicode Replacement
Character. If that replacement makes data invalid (for example,
because it turns a date field into something unparseable), print a
warning to `stderr` and drop the row from your output.

You can assume that the sample data we provide will contain all date
and time format variants you will need to handle.
