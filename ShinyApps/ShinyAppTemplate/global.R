###  a ShinyApp to visually explore conditional survival probabilities
# 
if( !exists("LoadPackages", mode="function")) source("FunctionsUsedByConditionalSurvivalApp.R")

LoadPackages()
enableBookmarking("url")
options(shiny.error = browser)

# load data as global objects
                    
