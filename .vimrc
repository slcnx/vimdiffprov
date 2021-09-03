if &diff
" 显示行号
  set nu
" 2个窗口同步滚动
  set scb
  set diffopt=filler,context:1000000  " filler is default and inserts empty lines for sync; context达到100000行或全文不变动的情况下，才会折叠
" more easy
  map [ [c
  map ] ]c
" https://vi.stackexchange.com/questions/10897/how-do-i-customize-vimdiff-colors/10898#10898
hi DiffAdd      ctermfg=NONE          ctermbg=LightGrey
hi DiffChange   ctermfg=NONE          ctermbg=LightGreen
hi DiffDelete   ctermfg=LightBlue     ctermbg=Red
hi DiffText     ctermfg=Yellow        ctermbg=Red
" enable mouse: mouse=a ; disable mouse: mouse=""
set mouse=""
endif

