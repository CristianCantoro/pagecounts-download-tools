Scripts to download the Wikipedia pageviews
--------------------------------------------

Scripts to download the Wikipedia page views.

## How-to download a month

1. clone the repository
```
git clone https://github.com/CristianCantoro/pagecounts-download-tools
```
2. go to the `sizes` directory and execute the download sizes:
```
╭─ ~/pagecounts-download-tools/sizes
╰─$ ./download_sizes.sh http://cricca.disi.unitn.it/datasets/pagecounts-raw-sorted/
```
3. go to the `downloadlists` directory and execute the download sizes:
```
╭─ ~/pagecounts-download-tools/downloadlists
╰─$ ./make_lists.sh ../sizes/2007-12.txt http://cricca.disi.unitn.it/datasets/pagecounts-raw-sorted/
```
4. from the repository base directory and dowload files:
```
╭─ ~/pagecounts-download-tools
╰─$ ./make_lists.sh ./download.sh -d 2007 1
```
