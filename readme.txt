Description
===========

This is a data exploration visualisation tool for London traffic accidents in 2016.


R / R-Studio
============

The visualisation tool has been created with R Shiny. 
The user must have R and R-Studio installed onto their computer to run the program.

R installation instructions can be found at: https://cran.r-project.org
R-Studio installation instructions can be found at: https://www.rstudio.com/products/rstudio/download/
An introduction to basic R commands can be found at: https://cran.r-project.org/doc/contrib/Paradis-rdebuts_en.pdf
Very few R-commands are required, just how to install packages, set the working directory and execute blocks of code.


Necessary Packages
===================

In addition to R and R-Studio, additional packages will be required to run the program.
Packages can be installed will the following command: install.packages(‘packageName’)
For example, to install the shiny package: install.packages(‘shiny’)
The loading of each library is included within the app.R code
The following libraries need to be installed:

‘dplyr’
‘ggplot2’
‘shiny’
‘shinydashboard’
‘leaflet’
‘lubridate’
‘RColorBrewer’


Running the Application
=======================

1) Extract the app.R and the dftRoadSafety_Accidents_2016.csv to an accessible location, for example Desktop.
2) Set the working directory within R-Studio to this same location. The R-syntax required to set the working directory will depend upon the OS. On Mac OS the syntax would be the following: setwd("/Users/username/Desktop/")
3) DO NOT EDIT ANY OF THE CODE. Merely run each section of the code using ‘cmd+Enter’. 
4) Once the visualisation tool is running, maximise to full screen and then read the on-screen text.
5) Press the small red STOP button on the edge of the R-Studio Console to stop the visualisation, so the R-Studio GUI is operable again.


Additional Visualisations
=========================

The code for the additional visualisations contained within the report are available within the additionalVisualisations.R file. The following packages will need to be installed in addition to the earlier ones to run the file:

‘gridExtra’
‘GGally’
