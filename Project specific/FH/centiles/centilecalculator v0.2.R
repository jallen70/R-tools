
library(shiny)
library(ggplot2)
library(dplyr)

cm <- read.csv("malecentiles.csv")
cw <- read.csv("femalecentiles.csv")

gcm <- read.csv("gamlassmalecentiles.csv")
gcw <-read.csv("gamlassfemalecentiles.csv")

gamlass_centiles <- TRUE

centile_script <- function(age, sex, nonhdl){ 
  
 # wd <- "H:/Jallens_homearea_DEC/Calculators/R/Centile calculator/"
wd <- "~/Documents/DEC WORK/FH/centiles"
  
 setwd(wd)
  
  if(!gamlass_centiles){
    
    if(sex == "Male") centiles <- cm
    if(sex == "Female") centiles <- cw
    
    age_group <- 0
    age_group <- ifelse(age <= 16, 1,age_group)
    age_group <- ifelse(age >= 16 & age <= 24, 2, age_group)
    age_group <- ifelse(age >= 25 & age <= 34, 3, age_group)
    age_group <- ifelse(age >= 35 & age <= 44, 4, age_group)
    age_group <- ifelse(age >= 45 & age <= 54, 5, age_group)
    age_group <- ifelse(age >= 55 & age <= 64, 6, age_group)
    age_group <- ifelse(age >= 65 & age <= 74, 7, age_group)
    age_group <- ifelse(age >= 75, 8, age_group)
    
    
    centile <- "NULL"
    
    for (i in 1:8)
    {
      centile <- ifelse(age_group == i & nonhdl >= centiles[i,9], 100, centile)
      centile <- ifelse(age_group == i & nonhdl >= centiles[i,8] & nonhdl < centiles[i,9], "99-100", centile)
      centile <- ifelse(age_group == i & nonhdl >= centiles[i,7]& nonhdl < centiles[i,8], "95-99", centile)
      centile <- ifelse(age_group == i & nonhdl >= centiles[i,6]& nonhdl < centiles[i,7], "90-95", centile)
      centile <- ifelse(age_group == i & nonhdl >= centiles[i,5]& nonhdl < centiles[i,6], "80-90", centile)
      centile <- ifelse(age_group == i & nonhdl >= centiles[i,4]& nonhdl < centiles[i,5], "75-80", centile)
      centile <- ifelse(age_group == i & nonhdl >= centiles[i,3]& nonhdl < centiles[i,4], "50-75", centile)
      centile <- ifelse(age_group == i & nonhdl >= centiles[i,2]& nonhdl < centiles[i,3], "25-50", centile)
      centile <- ifelse(age_group == i & nonhdl < centiles[i,2] , "<25", centile)
    }
    
  }
  
  
  if (gamlass_centiles){
    if(sex == "Male") centiles <- gcm
    if(sex == "Female") centiles <- gcw
    
    
    centiles$X <- NULL
    rownames(centiles) <- centiles$age - 15
    
    ageindex <- age - 15
    ageindex[ageindex < 0] <- 0
    
    centile <- "NULL"
    
    centile <- ifelse(ageindex >0 & nonhdl >= centiles[ageindex,8], ">99.5", centile)
    centile <- ifelse(ageindex >0 & nonhdl >= centiles[ageindex,7]& nonhdl < centiles[ageindex,8], "99-99.5", centile)
    centile <- ifelse(ageindex >0 & nonhdl >= centiles[ageindex ,6]& nonhdl < centiles[ageindex,7], "97.5-99", centile)
    centile <- ifelse(ageindex >0 & nonhdl >= centiles[ageindex,5]& nonhdl < centiles[ageindex,6], "95-97.5", centile)
    centile <- ifelse(ageindex >0 & nonhdl >= centiles[ageindex,4] & nonhdl < centiles[ageindex,5], "90-95", centile)
    centile <- ifelse(ageindex >0 & nonhdl >= centiles[ageindex,3]& nonhdl < centiles[ageindex,4], "80-90", centile)
    centile <- ifelse(ageindex >0 & nonhdl >= centiles[ageindex,2]& nonhdl < centiles[ageindex,3], "75-80", centile)
    centile <- ifelse(ageindex >0 & nonhdl < centiles[ageindex,2], "<75", centile)
    
    
    
  }
  
  # plots
  centiles <- as.data.frame(centiles)
  centiles <- centiles[with(centiles,order(age)), ]
  
  dist <- ggplot(centiles, aes(x = age, y = X75., colour = "red"))
  dist <- dist + geom_line(na.rm = TRUE)   + geom_line(aes(x = age, y = X80., colour = "blue")) +
    geom_line(aes(x = age, y = X90., colour = "green")) + geom_line(aes(x = age, y = X95., colour = "orange"))+ 
    geom_line(aes(x = age, y = X97.5., colour = "purple"))+
    geom_line(aes(x = age, y = X99., colour = "cyan")) + geom_line(aes(x = age, y = X99.5., colour = "brown")) + 
    xlim(0,120)+ ylab("nonHDL (mmol/L)") +     xlab("Age")  
  dist
  
  
  
  centile = 
    data.frame(
      Name = c("Age", "Sex", "nonHDL","Centile band"),
      Value = c(age, sex, nonhdl,centile))
  
  
  
  return(centile)
  
}



ui<-fluidPage(
  
 tags$style(type="text/css",
             ".shiny-output-error { visibility: hidden; }",
             ".shiny-output-error:before { visibility: hidden; }"
  ),
  
  titlePanel(h4("nonHDL centile calculator")),
  
  sidebarLayout(
        #  Application title
     # headerPanel("Centile calculator"),
      
      # Sidebar with sliders that demonstrate various available options
      sidebarPanel(
        
        
        radioButtons("sex", label = h3("Sex"), 
                     choices = list("Male" = "Male", "Female" = "Female"),
                     selected = "Male"),
        
        numericInput("age", label = h3("Age"), value = 30, min =20, max = 120, step = 1),
        
        numericInput("nonhdl", label = h3("NonHDL"), value = 2.5, min = 2, max = 12, step = 0.01),
        actionButton("goButton", "Calculate!")
        
    ),
    mainPanel(
      # output the centile
        tableOutput("view"),
        tags$br(),
        textOutput("text1"),
        plotOutput("centilePlot"),
        tags$b("Cite as:"),
        tags$br(),
        "Joy Allen, Dermot Neely",
        tags$br(),
        tags$em("A web application to calculate age and gender specific centiles for nonHDL cholesterol"),
        tags$br(),
        "NIHR Diagnostic Evidence Co-operative Newcastle. March 2017",
        tags$br(),
        verbatimTextOutput("lines")
    )
  )
)



#######################################################

#################    server     ################

server<-function(input, output) {
  output$age <- renderPrint({ input$age })
  output$value <- renderPrint({ input$sex })
  output$nonhdl <- renderPrint({ input$nonhdl })
  
  formula <-reactive({
     centile_script(input$age, input$sex, input$nonhdl)
  })
    #samplesize(input$prev, input$SnI, input$CI, input$alpha, input$beta)
  
        output$view <- renderTable({
      formula()
    })
        
        output$centilePlot<-renderPlot({
          
          if(!gamlass_centiles){
            if(input$sex == "Male") centiles <- cm
            if(input$sex == "Female") centiles <- cw
          }
          
          if (gamlass_centiles){
            if(input$sex == "Male") centiles <- gcm
            if(input$sex == "Female") centiles <- gcw
          }
          
          centiles <- as.data.frame(centiles)
          centiles <- centiles[with(centiles,order(age)), ]
          
          input_age <- input$age
          if(input$age <16 | input$age > 120) input_age <- 30
          
          
          dist <- ggplot(centiles, aes(x = age, y = X75.), colour = "red", size =1)
          dist <- dist + geom_line(aes(x = age, y = X75.), colour = "red", size =1)   + 
            geom_line(aes(x = age, y = X80.), colour = "blue", size =1.25) +
            geom_line(aes(x = age, y = X90.), colour = "green", size = 1.25) + 
            geom_line(aes(x = age, y = X95.), colour = "orange", size = 1.25) + 
            geom_line(aes(x = age, y = X97.5.), colour = "purple", size = 1.25) +
            geom_line(aes(x = age, y = X99.), colour = "cyan", size = 1.25) + 
            geom_line(aes(x = age, y = X99.5.), colour = "brown", size = 1.25) + 
            xlim(0,120)+ ylim(2.5,12) + ylab("nonHDL (mmol/L)") +     xlab("Age")  + 
            ggtitle(paste(input$sex, "centile plots")) + geom_point(aes(x = input_age, y = input$nonhdl), size = 5) + 
              annotate("text", label = "75%",colour = "red", size = 6, x = 115, y = 3.75) +
              annotate("text", label = "80%",colour = "blue", size = 6,  x = 115, y = 4) +
              annotate("text", label = "90%",colour = "green", size = 6,  x = 115, y = 4.5) +
              annotate("text", label = "95%",colour = "orange", size = 6, x = 115, y = 5.0) +
              annotate("text", label = "97.5%",colour = "purple", size = 6,  x = 115, y = 5.50) + 
              annotate("text", label = "99%",colour = "cyan", size = 6,  x = 115, y = 6.0) +
              annotate("text", label = "99.5%",colour = "brown", size = 6,  x = 115, y = 6.5) +
             theme(plot.title = element_text(size = 14, face = "bold")) 
          
          
          
          dist
        })
        
        output$text1 <- renderText({ 
          if(input$age <16 | input$age > 120) {
            paste0("Cannot calculate centile position, age must be >16 and less than 120") 
          }
          
        })

  
}


shinyApp(ui=ui, server=server)
