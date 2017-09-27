
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#


# data = data.frame(x= c(1,2,3),y= c(1,2,3))

shinyServer(function(input, output) {
    values = reactiveValues(data = data.frame(x= c(1,2,3),y= c(1,2,3),
                                              type = c(iconsToUse['archer'],
                                                       iconsToUse['swordman'],
                                                       iconsToUse['dragon']),
                                              picked = FALSE),
                            pickedPointPast = data.frame(),
                            pickedPointNow = data.frame(),
                            pointToMove = 0,
                            order = 0)
    
    # which points to move
    observe({
        # input$plot_brush
        input$plot_click
        # browser()
        isolate({
            click = nearPoints(values$data, input$plot_click,addDist = TRUE,maxpoints = 1,threshold = 10)
            # pointBrush =  brushedPoints(isolate(values$data), input$plot_brush)
            if(nrow(click)>0){
                selected = click
            }
            # if(nrow(pointBrush)>0){
            #     selected = pointBrush
            # }
            if(exists('selected')){
                selected[,c('x','y')] %>% apply(1,function(x){
                    whichRow = values$data$x %in% x['x'] & 
                        values$data$y %in% x['y']
                }) %>% apply(1,function(x){
                    any(x)
                }) %>% which -> toMove
                # values$pointToMove = toMove
                
                if(all(toMove %in%  values$pointToMove)){
                    values$pointToMove = 0
                } else{
                    values$pointToMove = toMove
                }
            }
            values$order = values$order + 1
            
        })
    })
    
    # coloring points to move
    observe({
        values$pointToMove
        isolate({
            picked = seq(nrow(values$data)) %in% values$pointToMove
            
            values$data$picked[picked] = TRUE
            values$data$picked[!picked] = FALSE
        })
    })
    
    # move pounts
    observe({
        values$order
        isolate({
            click = nearPoints(values$data, input$plot_click,addDist = TRUE,maxpoints = 1,threshold = 15)
            if(nrow(click)==0 & values$pointToMove !=0 & !is.null(input$plot_click)){
                values$data[values$pointToMove,]$x = input$plot_click$x
                values$data[values$pointToMove,]$y = input$plot_click$y
                
            }
        })
    })
    ########
    # observe({
    #     input$plot_click
    #     input$plot_brush
    #     
    #     isolate({
    #     values$pickedPointPast = values$pickedPointNow
    #     
    #     pointClick = nearPoints(isolate(values$data), input$plot_click,addDist = TRUE,maxpoints = 1)
    #     pointBrush =  brushedPoints(isolate(values$data), input$plot_brush)
    #     if(nrow(pointBrush)>0){
    #         values$pickedPointNow  = pointBrush
    #     } else{
    #         values$pickedPointNow  = pointClick
    #     }
    #     if(nrow(values$pickedPointNow)>0){
    #         values$pickedPointPast = values$pickedPointNow
    #     }
    #     })
    # })
    # 
    # 
    # observe({
    #     values$pickedPointPast
    #     values$pickedPointNow
    #     
    #     isolate({
    #         if(nrow(values$pickedPointPast)>0){
    #             isolate({
    #                 whichRow = values$data$x %in% values$pickedPointPast$x &
    #                     values$data$y %in% values$pickedPointPast$y
    #                 values$data[whichRow,]$picked = TRUE
    #                 values$data[!whichRow,]$picked= FALSE
    #             })
    # 
    #         }
    #         
    #         if(nrow(values$pickedPointPast)==1 & nrow(values$pickedPointNow) ==0 & !is.null(input$plot_click)){
    #             isolate({
    #                 whichRow = values$data$x %in% values$pickedPointPast$x & 
    #                     values$data$y %in% values$pickedPointPast$y 
    #                 values$data[whichRow,]$x = input$plot_click$x
    #                 values$data[whichRow,]$y = input$plot_click$y
    #             })
    #         }
    #     })
    # 
    # })
    
    ######
  output$plot <- renderPlot({
      values$data %>% ggplot(aes(x = x, y= y,color = picked, label = type)) +
          # geom_point(size = 20) +  
          coord_cartesian(xlim = c(0, 5),
                          ylim = c(0,5))  +
          geom_text(family='game-icons',size = 15)

  })
  
  # output$click_info = renderPrint({
  #     input$plot_click
  # })
  # 
  # output$brush_info = renderPrint({
  #     input$plot_brush
  # })
  # 
  output$pickedPoints = renderPrint({
      values$pointToMove
  })

})
