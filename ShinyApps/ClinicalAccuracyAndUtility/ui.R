#################### ui for ShinyApp to explore clinical accuracy and utility ###############################

ui <- function(request) {

  navbarPage(title = NULL,
    navbarMenu("Information",
    tabPanel("Introduction", br(), br(), includeHTML("www/tab1 2.html")), 
    tabPanel("How to read graph 0", includeHTML("www/tab2 2.html")),
    tabPanel("How to read graph 1", includeHTML("www/tab3 2.html")),
    tabPanel("How to read graph 2", includeHTML("www/tab4.html"))#,
    ),
    
  
     tabPanel("Explore clinical accuracy and utility of diagnostic tests",
    
                 sidebarPanel(
                    fluidRow(
                    actionButton("GoButton", "Update the graphs (will take a while)", class = 'middleAlign'),
                     hr(),
                      textInput(inputId = "DxPopulation", label = "Population", value = "<population>"),
                      textInput(inputId = "DxCondition", label = "Name of condition", value = "<condition>"),
                      textInput(inputId = "DxTestName", label = "Name of test", value = "<test>"),
                     hr(),
                     h4("Population and accuracy data"),
                      column(6,numericInput("prevalence", "Prevalence", min=0, max=1, value=0.4, step = 0.01, width = '400px')),
                      column(6,numericInput("n", paste("Study", "size", sep = "\n"), min=1, max=1000, value=300, width = '400px')),
                 
                      column(6, numericInput("sensitivity", "Sensitivity of test", min=0, max=1, value= 0.90, step = 0.01, width = '400px')),
                      column(6, numericInput("specificity", "Specificity of test", min=0, max=1, value= 0.80, step = 0.01, width = '400px')),

                    column(12, hr()),
                     h4("Data for clinical decisions"),
                     textInput(inputId = "DxRuleInDecision"
                               , label = "Rule-in decision", value = "<e.g. treat>"),
                     numericInput("RuleInDecisionThreshold", "Rule-in PPV threshold", min=0, max=1, value= 0.5, step = 0.01, width = '350px'),
                
                     textInput(inputId = "IndeterminateDecision", label = "Indeterminate decision", value = "<e.g. investigate further>"),
                 
                     textInput(inputId = "DxRuleOutDecision", label = "Rule-out decision", value = "<e.g. do not treat>"),
                     numericInput("RuleOutDecisionThreshold", "Rule-out NPV threshold", min=0, max=1, value= 0.1, step = 0.01),
                 checkboxInput('disper', 'Display as percentages?', value = FALSE), 
                 checkboxInput('disthres', 'Display as decision making thresholds?', value = TRUE), 
                 hr(),
                 bookmarkButton()
                   )
                 ),
                 mainPanel(
                   br(),
                   br(),
                   span(textOutput("validtext"), style="color:red"),
                     span(style="color: rgb(0, 0, 153)",
                          h4(textOutput("cmHeading"))),
                     span(h4( withSpinner(tableOutput("df2x2Table"),type = 6), align = "center", style="color:#4169E1; font-weight:bold;font-size: 15px")),
                     span(style="color: rgb(0, 0, 153)",
                          h6("(The numbers may not be integers because they are calculated from the study size, 
                             prevalence, sensitivity, and specificity.)"),
                          br(),
                          h4(tags$b("Graph 0. "), "How sensitivity and specificity reflect diagnostic accuracy"),
                          h5("(True and false positives (Tp, Fp), False and true negatives (Fn, Tn))")),
                          h5("Absolute values (left) and proportions (right)"),
                          withSpinner(plotOutput("RuleInOutPlot0"), type = 6),
                     br(),
              
                       span(style="color: rgb(0, 0, 153)",
                       h4(tags$b("Graph 1. "), "How post-test probabilities depend on prevalence"),
                       h5("(And sensitivity, and specificity)")),
                       withSpinner(plotOutput(paste0("PrePostProb2")), type = 6),
                       br(),
              
                     br(), 
                       span(style="color: rgb(0, 0, 153)",
                       h4(tags$b("Graph 2. "), "How diagnostic decisions depend on both the test result (positive or negative) and thresholds for decisions"),
                       h5("(And prevalence, sensitivity, and specificity)")),
                       withSpinner(plotOutput("RuleInOutPlot2"), type = 6),
                    br()
               )
        ),
    
    tabPanel("Download report for printing and sharing",
             p("This document contains all the tables and figures generated from your input data."),
             radioButtons('format', 'Please select the document format you require', 
                          c('PDF', 'HTML', 'Word'),
                          inline = TRUE),
             downloadButton('downloadReport', 'Download summary report'),
             br(), br(), 
             p("NB generating the document can take some time.")
    ),
     
    

###################################
#
#     credits as a running footer
#
      tags$hr(),
      wellPanel(
        tags$p(style="text-align: left", "Cite as:"),
        tags$p("Michael Power, Sara Graziadio and Joy Allen."),
        tags$em("A ShinyApp tool to explore dependence of rule-in and rule-out decisions on prevalence, sensitivity, specificity, and confidence intervals"),
        tags$p("NIHR Diagnostic Evidence Co-operative Newcastle. July 2017"),
        tags$br(),
        tags$img(src = "nihr-logo.jpg", width = "80px", height = "28px", align = "right") # add the NIHR logo)
      ))

}
