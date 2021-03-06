###  a ShinyApp to visually explore the effects of sensitivity, specificity, and prevalence
### on True positives, False positives, False negatives, and True negatives.

library(shiny)
library(ggplot2)
library(dplyr)

# formula to calculate confidence limits for a proportion, x, and sample size n 
ci<-function(x,n){
  1.96*sqrt(x*(1-x)/n)
}

ui<-fluidPage(

  titlePanel(h4("Visually explore the effects of sensitivity, specificity, and prevalence on True positives, False postives, False negatives, True negatives")),
  
  sidebarLayout(
    sidebarPanel(
     
      tags$h3("Input Variables"),
      sliderInput("n", "population", min=1, max=1000, value=100),
      sliderInput("prevalence", "prevalence of condition", min=0, max=1, value=.1),
      sliderInput("sensitivity", "sensitivity of index test", min=0, max=1, value= 0.90),
      sliderInput("specificity", "specificity of index test", min=0, max=1, value= 0.80),
      checkboxInput("sorted", label = "Population sorted by presence of condition and test result", value = FALSE)
  
    ),
    mainPanel(
      plotOutput("populationPlot"),
      tags$br(),
      plotOutput("testedPlots"),
      verbatimTextOutput("Dx2x2Tbl"),
      tags$br(),
      verbatimTextOutput("pv"),
      tags$br(),
      tags$b("Cite as:"),
      tags$br(),
      "Michael Power, Joy Allen.",
      tags$br(),
      tags$em("A web app to explore prevalence, sensitivity, and specificity on Tp, Fp, Fn, and Tn"),
      tags$br(),
      "NIHR Diagnostic Evidence Co-operative Newcastle. August 2016"
    )
  )
)

server<-function(input, output) {
    
    Dpos <- reactive({round(input$n * input$prevalence)})
    Dneg <- reactive({round(input$n - Dpos())})
    
    Tp <- reactive({round(input$sensitivity * Dpos())})  ### this might be 1 too much???
    Tn <- reactive({round(input$specificity * Dneg())})
    
    
    Fn <- reactive({round((1 - input$sensitivity) * Dpos())})
    Fp <- reactive({round((1 - input$specificity) * Dneg())})
    

    linesDf <- reactive({
        Dpos <- (input$n * input$prevalence)
        Dneg <- input$n - Dpos
        Fn <- (1 - input$sensitivity) * Dpos
        TN <- input$specificity * Dneg
        
        return({data.frame(
          ### define computed line segments for vertical line separating Dpos from Dneg    
          vx = Dpos /input$n,
          vxlci = Dpos /input$n - ci(Dpos /input$n, input$n),
          vxuci = Dpos /input$n + ci(Dpos /input$n, input$n),
          
          ### define computed line segments for horizontal lines separating TestPos from TestNeg    
          hy1 = Fn/Dpos,  
          hy1lci = Fn/Dpos - ci(Fn/Dpos, input$n),
          hy1uci = Fn/Dpos + ci(Fn/Dpos, input$n),

          hy2 = Tn/Dneg,
          hy2lci = Tn/Dneg - ci(Tn/Dneg, input$n),
          hy2uci = Tn/Dneg + ci(Tn/Dneg, input$n),
        )}
      )})
    

    dx2x2df <- reactive({data.frame(Dpos = Dpos(), Dneg = Dneg(), Tp = Tp(), Fp = Fp(), Fn = Fn(), Tn = Tn(), Tpos = Tp() + Fp(), Tneg = Fn() + Tn(), row.names = "")})
    temp <- reactive({data.frame(Dpos = Dpos(), Dneg = Dneg(), Tp = Tp(), Tn = Tn(), Fp = Fp(), Fn = Fn(), Tpos = Tp() + Fp(), Tneg = Fn() + Tn(), row.names = "")})
    
    # dx2x2Table <- reactive({
    # 
    #   Dpos <- (input$n * input$prevalence)
    #   Dneg <- input$n - Dpos
    #   Fn <- (1 - input$sensitivity) * Dpos
    #   TN <- input$specificity * Dneg
    #   Tp <- input$sensitivity * Dpos
    #   Fp <- (1 - input$specificity) * Dneg
    #   
    #   return(
    #     data.frame(
    #       ConditionPresent = c(Tp, Fn, Dpos),
    #       ConditionAbsent = c(Fp, Tn, Dneg),
    #       Totals = c(Tp + Fp, Fn + Tn, input$n),
    #       row.names = c("Test positive", "Test negative", "Totals")
    #     )
    #   )
    # })

    cmX1 <- reactive({0.5 * Dpos()/input$n})
    cmX2 <- reactive({Dpos()/input$n + 0.5*Dneg()/input$n})# x for Tp
    cmX3 <- reactive({0.5 * Dpos()/input$n})
    cmX4 <- reactive ({Dpos()/input$n + 0.5*Dneg()/input$n })
    cmX <- reactive({c(cmX1(),cmX2(),cmX1(),cmX2())})
    
    cmY1 <-reactive({ (Fn() + 0.5 * Tp())/input$n})
    cmY2 <-reactive({ (Tn() + 0.5 * Fp())/input$n})
    cmY3 <- reactive({ (0.5*Fn())/input$n})
    cmY4 <- reactive({ (0.5*Tn())/input$n })
    cmY <- reactive({c(cmY1(),cmY1(),cmY2(),cmY2())})
  
### coordinates and labels for contingency matrix graphic
    contingencyM <- reactive({
      Dpos <- (input$n * input$prevalence)
      Dneg <- input$n - Dpos
      Fn <- (1 - input$sensitivity) * Dpos
      TN <- input$specificity * Dneg
      Tp <- input$sensitivity * Dpos
      Fp <- (1 - input$specificity) * Dneg
      
      return({data.frame(
      cmX = c(
        0.5 * Dpos/input$n,          # Tp 
        (Dpos + 0.5*Dneg)/input$n,   # Fp
        0.5 * Dpos/input$n,          # Fn
        (Dpos + 0.5*Dneg)/input$n,   # Tn
        0.5 * Dpos/input$n,          # ppv
        (Dpos + 0.5*Dneg)/input$n    # npv
        ),
      cmY = c(
        (Fn + 0.5*Tp)/(Fn + Tp),        #Tp
        (Tn + 0.5*Fp)/(Tn + Fp),        #Fp
        0.5 * Fn/(Fn + Tp),             #Fn
        0.5 * Tn/(Tn + Fp),             #Tn
        (Fn + 0.5*Tp)/(Fn + Tp) - 0.04, #ppv
        0.5 * Tn/(Tn + Fp) - 0.04       #npv
        
      ), 
      labs = c(
        paste("Tp = ", Tp),
        paste("Fp = ", Fp),
        paste("Fn = ", Fn),
        paste("Tn = ", Tn),
        paste("ppv = ", paste(format(100*Tp / (Tp + Fp), digits = 2), "%")),
        paste("npv = ", paste(format(100*Tp / (Tn + Fn), digits = 2), "%"))
        )
      )
      })
      })

    pvdf <- reactive({
      Dpos <- (input$n * input$prevalence)
      Dneg <- input$n - Dpos
      Fn <- (1 - input$sensitivity) * Dpos
      TN <- input$specificity * Dneg
      Tp <- input$sensitivity * Dpos
      Fp <- (1 - input$specificity) * Dneg
      
            return(
        data.frame(
          PredictiveValues = c(
            paste(format(100*Tp / (Tp + Fp), digits = 3), "%", sep = ""),
            paste(format(100*Tn / (Tn + Fn), digits = 3), "%", sep = "")
            ),
          AtPrevalence = c(paste(format(100*input$prevalence, digits = 2), "%", sep = "")),
          . = c("Sensitivity", "Specificity"),
          LL95CI = c(
            paste(trimws(format(100*(input$sensitivity - ci(input$sensitivity, input$n)), digits = 2)), "%", sep = ""),
            paste(trimws(format(100*(input$specificity - ci(input$specificity, input$n)), digits = 2)), "%", sep = "")),
          Mid = c(
            paste(trimws(format(100*input$sensitivity, digits = 2)), "%", sep = ""),
            paste(trimws(format(100*input$specificity, digits = 3)), "%", sep = "")
            ),
          UL95CI = c(
            paste(trimws(format(100*(input$sensitivity + ci(input$sensitivity, input$n)), digits = 2)), "%", sep = ""),
            paste(trimws(format(100*(input$specificity + ci(input$specificity, input$n)), digits = 2)), "%", sep = "")),
          row.names = c("ppv", "npv")
            )
        )
    })
    populationdf <- reactive( {
      
      Dpos <- (input$n * input$prevalence)
      Dneg <- input$n - Dpos
      Fn <- (1 - input$sensitivity) * Dpos
      TN <- input$specificity * Dneg
      Tp <- input$sensitivity * Dpos
      Fp <- (1 - input$specificity) * Dneg

      if (input$sorted){
        x = c(
          runif(Tp, min = marginInsidePlot, max = Dpos/input$n) - marginInsidePlot,
          runif(Fn, min = marginInsidePlot, max = Dpos/input$n) - marginInsidePlot,
          runif(Fp, min = Dpos/input$n + marginInsidePlot, max = 1 - marginInsidePlot),
          runif(Tn, min = Dpos/input$n + marginInsidePlot, max = 1 - marginInsidePlot)
        )
        y = c(
          runif(Tp, min = Fn/(Tp + Fn) + marginInsidePlot, max = 1 - marginInsidePlot),
          runif(Fn, min = marginInsidePlot, max =  Fn/(Tp + Fn)) - marginInsidePlot,
          runif(Fp, min = Tn/(Fp + Tn) + marginInsidePlot, max = 1 - marginInsidePlot),
          runif(Tn, min = marginInsidePlot, max = Tn/(Fp + Tn) - marginInsidePlot)
        )
        
      } else {
        x = c(runif(input$n, min = marginInsidePlot, max = 1 - marginInsidePlot))
        y = c(runif(input$n, min = marginInsidePlot, max = 1 - marginInsidePlot))
      }
      
      
    return( {
     data.frame(
       ID = 1:input$n,
        condition = c(
          rep(paste("Present  = ", Dpos), times = Dpos),
          rep(paste("Absent = ",Dneg), times = Dneg)
        ),
       conditionShape = c(
         rep(21, times = Dpos),
         rep(22, times = Dneg)
       ),
       
       testResult = c(
         rep(paste("TestPos = ", Tp + Fp), times = Tp + Fp),
         rep(paste("TestNeg = ", Fn + Tn), times = Fn + Tn) 
       ),
       
       result = c(
         rep(paste("TruePos = ", Tp), times = Tp),
         rep(paste("FalseNeg = ", Fn), times = Fn), 
         rep(paste("FalsePos = ", Fp), times = Fp), 
         rep(paste("TrueNeg = ", Tn), times = Tn)
       ),
       resultShape = c(
         rep(21, times = Tp),
         rep(22, times = Fn), 
         rep(23, times = Fp), 
         rep(24, times = Tn)
       ),
       x, 
       y
    )
  })
})
    


#  output$Dx2x2Tbl <- renderPrint(dx2x2Table())
  
  marginInsidePlot = 0.01
    
  output$populationPlot<-renderPlot({

      p1 <- ggplot(populationdf(), aes(x=x, y=y, color=condition, shape = condition)) + geom_point(size = 4) +
       scale_color_manual(values=c("#999999", "#E69F00")) 
      if (input$sorted) {
       p1 <- ggplot(populationdf(), aes(x=x, y=y, color=condition, shape = condition)) + 
         geom_point(size = 4) + #scale_color_manual(values=c("#999999", "#E69F00"))  +
         geom_segment(aes(x = vx, y = 0, xend = vx, yend = 1, colour = NULL, shape = NULL), 
                      data = linesDf()) +
         geom_segment(aes(x = vxlci, y = 0, xend = vxlci, yend = 1, colour = NULL, shape = NULL), 
                      data = linesDf()) +
         geom_segment(aes(x = vxuci, y = 0, xend = vxuci, yend = 1, colour = NULL, shape = NULL), 
                      data = linesDf()) 
      }
      
      p1 <- p1 +
        theme(
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks = element_blank()
        ) +
        labs(x = "", y = "") +
        ggtitle("Population of people with and without a condition")
           p1

  })


  
  output$testedPlots<-renderPlot( {

    p2 <- ggplot(populationdf(), aes(x=x, y=y, color=condition, shape = result)) + geom_point(size = 4)
   
    if (input$sorted) {
        p2 <- p2 + 
          ### vertical line with 95% CIs to separate Condition present/absent
          geom_segment(aes(x = vx, y = 0, xend = vx, yend = 1, colour = NULL, shape = NULL), 
                       data = linesDf()) +
          geom_segment(aes(x = vxlci, y = 0, xend = vxlci, yend = 1, colour = NULL, shape = NULL), 
                       data = linesDf()) +
          geom_segment(aes(x = vxuci, y = 0, xend = vxuci, yend = 1, colour = NULL, shape = NULL), 
                       data = linesDf()) +

          ### horizontal line with 95% CIs to separate Tp from Fn          
          geom_segment(aes(x = 0, y = hy1, xend = vx, yend = hy1, colour = NULL, shape = NULL), 
                     data = linesDf()) + 
          geom_segment(aes(x = 0, y = hy1lci, xend = vx, yend = hy1, colour = NULL, shape = NULL), 
                       data = linesDf()) + 
          geom_segment(aes(x = 0, y = hy1uci, xend = vx, yend = hy1, colour = NULL, shape = NULL), 
                       data = linesDf()) + 
          
          
          ### horizontal line with 95% CIs to separate Fp from Tn          
          geom_segment(aes(x = vx, y = hy2, xend = 1, yend = hy2, colour = NULL, shape = NULL), 
                       data = linesDf()) + 
          geom_segment(aes(x = vx, y = hlci2, xend = 1, yend = hlci2, colour = NULL, shape = NULL), 
                       data = linesDf()) + 
          geom_segment(aes(x = vx, y = hy2uci, xend = 1, yend = hy2uci, colour = NULL, shape = NULL), 
                       data = linesDf()) + 
          
          ### label the cells of the contingency matrix 
          geom_text(data = contingencyM(), size = 5, aes(x = cmX, y = cmY, label = labs, colour = NULL, shape = NULL))
    }
        theme(
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank()
        ) +
        labs(x = "", y = "") +
        ggtitle("Population of people with test results: true and false positive; false and true negative")
    p2
    
  })

  
  output$stats <- renderPrint((dx2x2df()))
  output$pv <- renderPrint(pvdf())
 
  output$popHead <- renderPrint((head(populationdf())))
  output$popTail <- renderPrint((tail(populationdf())))
  output$temp <- renderPrint(contingencyM())
  

}

shinyApp(ui=ui, server=server)
