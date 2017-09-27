
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

                                   
shinyUI(fluidPage(

  # Application title
  titlePanel("Meh"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(# verbatimTextOutput("click_info"),
                 # verbatimTextOutput("brush_info"),
                 verbatimTextOutput("pickedPoints")),
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("plot",click = "plot_click")
    )
  )
))
