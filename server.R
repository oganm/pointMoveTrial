
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#


# data = data.frame(x= c(1,2,3),y= c(1,2,3))

shinyServer(function(input, output) {
    values = reactiveValues(
        # data = data.frame(x= c(150,250,350),y= c(150,250,350),
        #                   type = c(1,
        #                            2,
        #                            3),
        #                   picked = FALSE,
        #                   team = c('blue','green','yellow')),
        data = data.frame(x = c(seq(50,750, 100), # pawns
                                coordinateConvert(c(1,8)), 
                                coordinateConvert(c(2,7)),
                                coordinateConvert(c(3,6)),
                                coordinateConvert(c(4,5)),
                                seq(50,750, 100), # pawns
                                coordinateConvert(c(1,8)), 
                                coordinateConvert(c(2,7)),
                                coordinateConvert(c(3,6)),
                                coordinateConvert(c(4,5))),
                          y = c(rep(150,8), # pawns
                                coordinateConvert(rep(1,8)),# everythin else
                                rep(650,8), # pawns
                                coordinateConvert(rep(8,8))), # everythin else
                          type = c(rep(iconsToUse$pawn,8),
                                   rep(iconsToUse$rook,2),
                                   rep(iconsToUse$knightChess,2),
                                   rep(iconsToUse$bishop,2),
                                   iconsToUse$queen,
                                   iconsToUse$kingChess,
                                   rep(iconsToUse$pawn,8),
                                   rep(iconsToUse$rook,2),
                                   rep(iconsToUse$knightChess,2),
                                   rep(iconsToUse$bishop,2),
                                   iconsToUse$queen,
                                   iconsToUse$kingChess),
                          picked = FALSE,
                          team = c('white'),
                          id = 1:32,
                          fontColor = c(rep('cornsilk3',16),
                                        rep('gray20', 16)),
                          backgroundTrans =0),
        pickedPointPast = data.frame(),
        pickedPointNow = data.frame(),
        pointToMove = 0,
        order = 0 # controls the order of operations upon clicking
    )
    
    nearThreshold = reactive({
        defaultSquareSize/2*(2^(input$plotZoom-2))
        })
    
    # which points to move
    observe({
        # input$plot_brush
        input$plot_click
        # browser()
        isolate({
            click = nearPoints(values$data, input$plot_click,addDist = TRUE,maxpoints = 1,threshold = nearThreshold())
            # pointBrush =  brushedPoints(isolate(values$data), input$plot_brush)
            if(nrow(click)>0){
                selected = click
            }
            # if(nrow(pointBrush)>0){
            #     selected = pointBrush
            # }
            if(exists('selected')){
                selected[,c('x','y','id')] %>% apply(1,function(x){
                    whichRow = values$data$x %in% x['x'] & 
                        values$data$y %in% x['y'] & 
                        values$data$id %in% x['id']
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
            values$data$picked[picked] = 'TRUE'
            values$data$picked[!picked] = values$data$fontColor[!picked] %>% as.character()
        })
    })
    
    # move pounts
    observe({
        values$order
        isolate({
            click = nearPoints(values$data, input$plot_click,addDist = TRUE,maxpoints = 1,threshold = nearThreshold())
            if(nrow(click)==0 & values$pointToMove !=0 & !is.null(input$plot_click)){
                allowedX = seq(0,plotSize['x'],gridSize) + gridSize/2
                allowedY = seq(0,plotSize['y'],gridSize) + gridSize/2
                
                values$data[values$pointToMove,]$x = allowedX[which.min(abs(allowedX - input$plot_click$x))]
                values$data[values$pointToMove,]$y = allowedY[which.min(abs(allowedY - input$plot_click$y))]
                
            }
        })
    })

  output$plot <- renderPlot({
      values$data %>% ggplot(aes(x = x, y= y,color = picked, label = type)) +
          scale_x_continuous(breaks = seq(0,plotSize['x'],gridSize)) + 
          scale_y_continuous(breaks = seq(0,plotSize['y'],gridSize)) + 
          background_grid(major = 'xy', minor = "none") + 
          # geom_point(size = 20) +  
          coord_cartesian(xlim = c(0, plotSize['x']),
                          ylim = c(0,plotSize['y']))  +
          geom_point(aes(color = team),alpha = values$data$backgroundTrans, shape = 15,size =  20*defaultSquareSize/50*(2^(input$plotZoom-2))) + 
          geom_text(family='game-icons',size = 18*defaultSquareSize/50*(2^(input$plotZoom-2))) + 
          scale_color_manual(name = 'Picked', values = c('FALSE' = defaultIconColor,
                                                         'TRUE' = pickedIconColor,
                                                         cols,
                                                         none = "#00000000"),guide=FALSE) + 
          theme(axis.line = element_blank(), 
                axis.text= element_blank(),
                axis.title = element_blank(),
                axis.ticks = element_blank())
              

  })
  
  output$htmlPlot <- renderUI({
      plotOutput("plot",
                 click = "plot_click",
                 height = defaultSquareSize*(plotSize/gridSize)['y']*(2^(input$plotZoom-2)) ,
                 width = defaultSquareSize*(plotSize/gridSize)['x']*2^(input$plotZoom-2))
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
