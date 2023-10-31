---
title: A very simple web scraper to get plant descriptions
date: '2023-08-19'
slug: web-scraping-foc
tags:
  - r
---

As I was writing a chapter on the Vegegraphy of China, I needed to categorize all the plant species that appeared in the plots according to their life forms. To accomplish this, I had to search for the characteristics of numerous plants. Although the digitized version of the [Flora of China](http://www.iplant.cn/foc) was accessible for free, it became tedious when I had to look up information for several hundred plants. However, I discovered that obtaining these descriptions automatically was a breeze with the help of R and its httr package. <!-- Unlike those who make grad students do every dirty job, I opted for an efficient approach using tools. --> Below is just an example of retrieving plant descriptions from the web, for a more general use of web scraping, more knowledge may be needed. A tutorial form [Omar Kamali](https://omarkama.li/blog/web-scraping-data-for-everyone) appears to be a good start.

To begin, I conducted a search for a specific plant in the Flora of China. Let's use "Ginkgo biloba" as an example, which is known as the [sole survivor of an important lineage of gymnosperm](https://jecologyblog.com/2022/05/05/cover-stories-ginkgo-biloba/). When I accessed the explorer, it redirected me to the URL http://www.iplant.cn/info/Ginkgo%20biloba?t=foc, where I could find the plant's detailed information. In order to retrieve this page in R, I utilized the `httr::GET()` function. However, the downloaded object did not contain the descriptions of the plants.

I tried to figure out what's going on here. I opened the URL in Firefox, and accessed the "web developer tool" by pressing `F12`. Then, turn to the "Network" tab, reload the page, and ensured the type "html" was selected. Apart from the request to  `/info/Ginkgo%20biloba`, there are two additional successful requests. One of them had the species' name in its URL: http://www.iplant.cn/ashx/getfoc.ashx?key=Ginkgo+biloba&key_no=&m=0.36896116848671234. I copied this URL into the explorer and discovered that it contained the species' description. The URL had three parameters following `getfoc.ashx`, namely 'key', 'key_no', and 'm'. It was evident that the "key" parameter represented the species name. Although I was unsure about the meaning of "key_no" and "m", the page displayed correctly even without these two parameters. To streamline this process, I defined a function that retrieves the URL for each species based on its name.

``` r
get_url <- function(sp) {
  urlbase = "http://www.iplant.cn/ashx/getfocn.ashx?key="
  spec = gsub(" sp.", "", sp)
  spestring = gsub(" ", "+", spec)
  urlstring = paste(urlbase, spestring, sep = "")
  return(urlstring)
}
```

To retrieve the page, run the `httr::GET()` function, and then extract the text using `httr::content()`. Now, let's examine the content of the page and determine how to obtain the required information.

``` r
sp = "Ginkgo biloba"
urlstring = get_url(sp)
page = httr::GET(urlstring)
cont = httr::content(page, "text")
descriptionlines = unlist(strsplit(cont, '\r\n'))
descriptionlines

##  [1] "{"  
##  [2] "  \"foccname\": \"银杏\","  
##  [3] "  \"focpinyin\": \"yin xing\"," 
##  [4] "  \"vol\": \"<a href='/foc/vol/4' style='font-size:16px'>Vol.4</a>\","  
##  [5] "  \"volyear\": \" (1999)\","  
##  [6] "  \"contenttitle\": \"1.<b>Ginkgo biloba</b> Linnaeus\"," 
##  [7] "  \"volfamily\": \" <span style='font-family:宋体;'>>></span> <a href='/info/Ginkgoaceae?t=foc'>Ginkgoaceae</a> <a href='/foc/fam/10370'><img src='/foc/images/icon-list.gif'></a>\","  
##  [8] "  \"familypdf\": \"<a href='/foc/pdf/Ginkgoaceae.pdf'>PDF</a>\"," 
##  [9] "  \"volgen\": \" <span style='font-family:宋体;'>>></span> <a href='/info/Ginkgo?t=foc'>Ginkgo</a> <a href='/foc/fam/113565'><img src='/foc/images/icon-list.gif'></a>\","  
## [10] "  \"genpdf\": \" <a href='//www.iplant.cn/foc/pdf/Ginkgo.pdf'>PDF</a>\"," 
## [11] "  \"imgtxt\": \"<a href='/foc/illast/Ginkgo biloba.jpg' class=\\\"highslide\\\" onclick=\\\"return hs.expand(this)\\\"><img style='width:230px;border:0'  src='/foc/illast/Ginkgo biloba.jpg' /></a></div>\","  
## [12] "  \"Comment\": \"<p>A relict species of the Mesozoic era, this and other (extinct) species of Ginkgo were formerly widespread throughout the world. The atavistic, leaf-marginal seeds of one cultivated\\nclone may suggest an affinity with the extinct pteridosperms. Ginkgo biloba is now a rare species in the wild, but has been widely cultivated as an ornamental, probably for more than\\n3000 years. It provides shade and is tolerant of a wide range of climatic and edaphic conditions, including pollution. It is sacred to Buddhists and is often planted near temples. The\\nwood is used in furniture making, the leaves are medicinal and used for pesticides, the roots are used as a cure for leucorrhea, the seeds are edible, and the bark yields tannin.</p>\","  
## [13] "  \"Description\": \"<p>Trees to 40 m tall; trunk to 4 m d.b.h.; bark light gray or grayish brown, longitudinally fissured especially on old trees; crown conical initially, finally broadly ovoid; long branchlets pale\\nbrownish yellow initially, finally gray, internodes (1-) 1.5-4 cm; short branchlets blackish gray, with dense, irregularly elliptic leaf scars; winter buds yellowish brown, ovate. Leaves with\\npetiole (3-)5-8(-10) cm; blade pale green, turning bright yellow in autumn, to 13 × 8(-15) cm on young trees but usually 5-8 cm wide, those on long branchlets divided by a deep, apical\\nsinus into 2 lobes each further dissected, those on short branchlets with undulate distal and margin notched apex. Pollen cones ivory colored, 1.2-2.2 cm; pollen sacs boat-shaped, with\\nwidely gaping slit. Seeds elliptic, narrowly obovoid, ovoid, or subglobose, 2.5-3.5 × 1.6-2.2 cm; sarcotesta yellow, or orange-yellow glaucous, with rancid odor when ripe; sclerotesta white, with 2 or 3 longitudinal ridges;\\nendotesta pale reddish brown. Pollination Mar-Apr, seed maturity Sep-Oct.</p>\","
## [14] "  \"habait\": \"<p>*  Scattered in broad-leaved forests and valleys on acidic, well-drained, yellow loess (pH = 5-5.5); 300-1100 m. Perhaps native in NW Zhejiang (Tianmu Shan); widely and long cultivated below 2000 m in Anhui, Fujian, Gansu, Guizhou, Henan, Hebei, Hubei, Jiangsu, Jiangxi, Shaanxi, Shandong, Shanxi, Sichuan, Yunnan.</p>\"," 
## [15] "  \"Synonym\": \"<p>&lt;I&gt;Salisburia adiantifolia&lt;/I&gt; Smith; &lt;I&gt;S. biloba&lt;/I&gt; (Linnaeus) Hoffmansegg.</p>\","  
## [16] "  \"sublist\": \"\""  
## [17] "}" 
```

I would like to include species name, common Chinese name, family of the species, details of the species, and the URL in the output file. 

Apparaently, the species name, "Ginkgo biloba", is same as input. The Chinese common name, "银杏", can be extracted by following these two steps. First, locate the line containing "foccname" using `cnameline = descriptionlines[grepl('foccname', descriptionlines)]`. The `grepl() `function returns `TRUE` when a certain string contains the given pattern. Then, extract the common name using `cname = gsub('  \"foccname\": \"(.*)\",', '\\1', cnameline, perl = T)`. The `gsub()` function searches for the given pattern (the first parameter) in the vector (the third parameter) and replaces it with the second parameter. In this case, the pattern is the entire "foccname" line, except for the common name, which is substituted by `.*` within brackets. The period `.` matches any single character, and the `*` means the preceding item will be matched zero or more times. Here, `.*` matches any characters between   `  \"foccname\": \"` and `\",`. The second parameter `\\1` represents the characters within the first pair of brackets, which corresponds to the characters matched by `.*`. The `gsub()` function replaces the entire "foccname" line with the desired Chinese common name, removing the unwanted characters.

``` r
# get common chinese name and family name from page content
get_cname <- function(cont){
  if (cont =="") {
    cname = NA
  } else {
    descriptionlines = unlist(strsplit(cont, '\r\n'))
    cnameline = descriptionlines[grepl('foccname', descriptionlines)]
    cname = gsub('  \"foccname\": \"(.*)\",', '\\1', cnameline, perl = T)
  }
  return(cname)
}

# get the family name from page content
get_family <- function(cont){
  if (cont =="") {
    fami = NA
  } else {
    descriptionlines = unlist(strsplit(cont, '\r\n'))
    familyline = descriptionlines[grepl('volfamily', descriptionlines)]
    fami = gsub(".*focn'>(.*)</a><a.*", '\\1', familyline, perl = T)
  }
  return(fami)
}

# get descriptions from content
get_desc_en <- function(cont) {
  if (cont =="") {
    desc = NA
  } else {
    contentlines = unlist(strsplit(cont, '\r\n'))
    descriptionlines = contentlines[grepl('Description', contentlines)]
    desc = gsub(" \"Description\": \"<p>(.*)</p><p>.*", "\\1", descriptionlines)
  }
  return(desc[1])
}
```

The similar two-step process can be repeated to extract the family and description of the species. It would be beneficial to define functions to perform these steps for future use.

The previously defined functions are utilized in the following function, which automates the process of retrieving species details, extracting relevant information, and organizing it accordingly.

```r
get_foc <- function(sp){
  # prepare url according to species name
  urlstring = get_url(sp)
  # GET content from webset
  cont = ""
  page = httr::GET(url = urlstring)
  if (page$status_code != 200) {
    cont = ""
  } else {
    cont = httr::content(page, "text")
  }
  # get names and descriptions
  cname = get_cname(cont)
  familyname = get_family(cont)
  desc_en = get_desc_en(cont)
  # result
  re = c(sp, cname, familyname, desc_en, urlstring)
  res = matrix(
    re,
    nrow = 1,
    ncol = length(re),
    byrow = TRUE)
  return(res)
}
```

Finally, it is time for a test run. I have selected several species as examples. I have defined a matrix called `result` where each column represents a variable and each row represents a species. To obtain the descriptions for each species, I have implemented a `for` loop. I have also included a short pause between each iteration using the `Sys.sleep()` function to prevent making too many requests in a short period of time. Additionally, in each iteration, a number will be printed on the screen to indicate the progress.

``` r
species = c("Ginkgo biloba", 
            "Cupressus chengiana var. jiangeensis", 
            "Pinus sp.", 
            "Hibiscus mutabilis", 
            "Circaeaster agrestis")
nospecies = length(species)
result = matrix(NA, nrow = length(species), ncol = 5)
for (i in 1:nospecies) {
  spname = species[i]
  re = get_foc(spname)
  result[i,] = re
  Sys.sleep(abs(rnorm(1)))
  print(i/nospecies)
}
```
