::  Helm: send message to an urbit
::
::::  /hoon/hi/hood/gen
  ::
/?    310
:-  %say
|=  [^ arg=$@(who=ship [who=ship mez=tape]) ~]
:-  %helm-send-hi
?@  arg  [who.arg ~]
[who `mez]:arg
