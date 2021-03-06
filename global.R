library(shiny)
library(ggplot2)
library(dplyr)
library(cowplot)
# library(extrafont)
library(stringr)
library(highlight)


setHeight = function(x){
    input$plotZoom*5
}

 # https://groups.google.com/forum/#!topic/shinyapps-users/0czcsM4vziM
print('starting')
gridSize = 100
plotSize = c(x = gridSize*8, y = gridSize*8)
defaultSquareSize = 20
defaultIconColor = 'black'
pickedIconColor = 'red'


dir.create('~/.fonts') 
file.copy('game-icons.ttf','~/.fonts/')
system('fc-cache -f ~/.fonts') 
# font_import( '.', prompt = FALSE)
# fonts()
print('fonts loaded')

fa_parsed = css.parser('game-icons.css')
fa_df =fa_parsed[str_detect(names(fa_parsed), ":before")] %>% purrr::map_chr(1) %>% 
    data_frame(char_raw = .,
               char  = str_extract(char_raw %>% tolower(), "[0-9a-f]+"),
               char_int = strtoi(char, 16L),
               codes = str_replace(names(.), ":before", ""))

print('fonts css parsed')


# iconsToUse = c(archer = intToUtf8(fa_df$char_int[fa_df$codes == 'gi-bowman']),
#                swordman = intToUtf8(fa_df$char_int[fa_df$codes == 'gi-swordman']))

iconsToUse = list(archer = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-bowman']),
               swordwoman = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-swordwoman']),
               swordman = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-swordman']),
               pikeman = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-pikeman']),
               knight = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-mounted-knight']),
               assassin = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-hooded-assassin']),
               spartan = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-spartan']),
               cavalry = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-cavalry']),
               peasant = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-farmer']),
               king = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-throne-king']),
               vampire = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-vampire-cape']),
               ninja = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-running-ninja']),
               zombie = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-shambling-zombie']),
               orc = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-orc-head']),
               goblin = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-goblin-head']),
               dragon = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-wyvern']),
               tree = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-evil-tree']),
               minotaur = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-minotaur']),
               spectre = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-sprectre']),
               demon = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-daemon-skull']),
               golem = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-robot-golem']),
               pawn = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-chess-pawn']),
               kingChess = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-chess-king']),
               knightChess = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-chess-knight']),
               queen = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-chess-queen']),
               bishop = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-chess-bishop']),
               rook = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-chess-rook']),
               chessboard = intToUtf8(fa_df$char_int[fa_df$codes == 'game-icon-empty-chessboard']))

cols = colors()
names(cols) = colors()


coordinateConvert = function(x){
    x*gridSize - gridSize/2
}

addAlpha <- function(col, alpha=1){
    if(missing(col))
        stop("Please provide a vector of colours.")
    apply(sapply(col, col2rgb)/255, 2, 
          function(x) 
              rgb(x[1], x[2], x[3], alpha=alpha))  
}
