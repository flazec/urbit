::  Kiln: make (subtree in) desk privately readable.
::
::::  /gen/hood/private/hoon
  ::
:-  %say
|=  $:  [now=@da eny=@uvJ bec=beak]
        arg=$@(des=desk [des=desk pax=path])
        ~
    ==
:-  %kiln-permission
?@  arg  [des.arg / |]
[des pax |]:arg
