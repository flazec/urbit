::  chat-view: sets up chat JS client, paginates data, and combines commands
::  into semantic actions for the UI
::
/-  *permission-store,
    *permission-hook,
    *group-store,
    *invite-store,
    *permission-group-hook,
    *chat-hook
/+  *server, *chat-json, default-agent
/=  index
  /^  octs
  /;  as-octs:mimes:html
  /:  /===/app/chat/index
  /|  /html/
      /~  ~
  ==
/=  tile-js
  /^  octs
  /;  as-octs:mimes:html
  /:  /===/app/chat/js/tile
  /|  /js/
      /~  ~
  ==
/=  script
  /^  octs
  /;  as-octs:mimes:html
  /:  /===/app/chat/js/index
  /|  /js/
      /~  ~
  ==
/=  style
  /^  octs
  /;  as-octs:mimes:html
  /:  /===/app/chat/css/index
  /|  /css/
      /~  ~
  ==
/=  chat-png
  /^  (map knot @)
  /:  /===/app/chat/img  /_  /png/
::
|%
+$  card  card:agent:gall
::
+$  poke
  $%  [%launch-action [@tas path @t]]
      [%chat-action chat-action]
      [%group-action group-action]
      [%chat-hook-action chat-hook-action]
      [%permission-hook-action permission-hook-action]
      [%permission-group-hook-action permission-group-hook-action]
  ==
--
^-  agent:gall
=<
  |_  bol=bowl:gall
  +*  this       .
      chat-core  +>
      cc         ~(. chat-core bol)
      def        ~(. (default-agent this %|) bol)
  ::
  ++  on-init
    ^-  (quip card _this)
    =/  launcha  [%launch-action !>([%chat-view /configs '/~chat/js/tile.js'])]
    :_  this
    :~  [%pass /updates %agent [our.bol %chat-store] %watch /updates]
        [%pass / %arvo %e %connect [~ /'~chat'] %chat-view]
        [%pass /chat-view %agent [our.bol %launch] %poke launcha]
    ==
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?>  (team:title our.bol src.bol)
    ?+    mark  (on-poke:def mark vase)
        %handle-http-request
      =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
      :_  this
      %+  give-simple-payload:app  eyre-id
      %+  require-authorization:app  inbound-request
      poke-handle-http-request:cc
    ::
        %json
      :_  this
      (poke-chat-view-action:cc (json-to-view-action !<(json vase)))
    ::
        %chat-view-action
      :_  this
      (poke-chat-view-action:cc !<(chat-view-action vase))
    ==
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    ?>  (team:title our.bol src.bol)
    |^
    ?:  ?=([%http-response *] path)
      [~ this]
    ?:  =(/primary path)
      ::  create inbox with 100 messages max per mailbox and send that along
      ::  then quit the subscription
      :_  this
      [%give %fact ~ %json !>((inbox-to-json truncated-inbox-scry))]~
    ?:  =(/configs path)
      [[%give %fact ~ %json !>(*json)]~ this]
    (on-watch:def path)
    ::
    ++  truncated-inbox-scry
      ^-  inbox
      =/  =inbox  .^(inbox %gx /=chat-store/(scot %da now.bol)/all/noun)
      %-  ~(run by inbox)
      |=  =mailbox
      ^-  ^mailbox
      [config.mailbox (truncate-envelopes envelopes.mailbox)]
    ::
    ++  truncate-envelopes
      |=  envelopes=(list envelope)
      ^-  (list envelope)
      =/  length  (lent envelopes)
      ?:  (lth length 100)
        envelopes
      (swag [(sub length 100) 100] envelopes)
    --
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?+    -.sign  (on-agent:def wire sign)
        %kick
      :_  this
      [%pass / %agent [our.bol %chat-store] %watch /updates]~
    ::
        %fact
      ?+  p.cage.sign  (on-agent:def wire sign)
          %chat-update
        :_  this
        (diff-chat-update:cc !<(chat-update q.cage.sign))
      ==
    ==
  ::
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    ?.  ?=(%bound +<.sign-arvo)
      (on-arvo:def wire sign-arvo)
    [~ this]
  ::
  ++  on-save  on-save:def
  ++  on-load  on-load:def
  ++  on-leave  on-leave:def
  ++  on-peek   on-peek:def
  ++  on-fail   on-fail:def
  --
::
::
|_  bol=bowl:gall
::
++  poke-handle-http-request
  |=  =inbound-request:eyre
  ^-  simple-payload:http
  =+  url=(parse-request-line url.request.inbound-request)
  ?+  site.url  not-found:gen
      [%'~chat' %css %index ~]  (css-response:gen style)
      [%'~chat' %js %tile ~]    (js-response:gen tile-js)
      [%'~chat' %js %index ~]   (js-response:gen script)
  ::
      [%'~chat' %img @t *]
    =/  name=@t  i.t.t.site.url
    =/  img  (~(get by chat-png) name)
    ?~  img
      not-found:gen
    (png-response:gen (as-octs:mimes:html u.img))
  ::
      [%'~chat' %paginate @t @t *]
    =/  start  (need (rush i.t.t.site.url dem))
    =/  end  (need (rush i.t.t.t.site.url dem))
    =/  pax  t.t.t.t.site.url
    =/  envelopes  (envelope-scry [(scot %ud start) (scot %ud end) pax])
    %-  json-response:gen
    %-  json-to-octs
    %-  update-to-json
    [%messages pax start end envelopes]
  ::
      [%'~chat' *]  (html-response:gen index)
  ==
::
++  poke-json
  |=  jon=json
  ^-  (list card)
  ?>  (team:title our.bol src.bol)
  (poke-chat-view-action (json-to-view-action jon))
::
++  poke-chat-view-action
  |=  act=chat-view-action
  ^-  (list card)
  |^
  ?>  (team:title our.bol src.bol)
  ?-  -.act
      %create
    ?^  (chat-scry path.act)
      ~&  %chat-already-exists
      ~
    %-  zing
    :~  (create-chat path.act security.act allow-history.act)
        (create-managed-group path.act security.act members.act)
        (create-security path.act security.act)
        ~[(permission-hook-poke [%add-owned path.act path.act])]
        %+  turn  ~(tap in members.act)
        |=  =ship
        (send-invite-poke path.act ship)
    ==
  ::
      %delete
    :~  (chat-hook-poke [%remove path.act])
        (permission-hook-poke [%remove path.act])
        (chat-poke [%delete path.act])
    ==
  ::
      %join
    :~  (chat-hook-poke [%add-synced ship.act path.act ask-history.act])
        (permission-hook-poke [%add-synced ship.act path.act])
    ==
  ==
  ::
  ++  create-chat
    |=  [=path security=rw-security history=?]
    ^-  (list card)
    :~  [(chat-poke [%create path])]
        [(chat-hook-poke [%add-owned path security history])]
    ==
  ::
  ++  create-managed-group
    |=  [=path security=rw-security ships=(set ship)]
    ^-  (list card)
    ~&  [path security ships]
    ?.  =(security %village)
      ::  if blacklist, do nothing but create the group if it isn't there
      ::
      ?~((group-scry path) ~[(group-poke [%bundle path])] ~)
    ::  if whitelist, check if group exists already. if yes, do nothing
    ::
    ?^  (group-scry path)  ~
    ::  if group does not exist, send contact-view %create
    ::
    ~[(contact-view-poke [%create path ships])]
  ::
  ++  create-security
    |=  [pax=path sec=rw-security]
    ^-  (list card)
    ?+  sec       ~
        %channel
      ~[(perm-group-hook-poke [%associate pax [[pax %black] ~ ~]])]
    ::
        %village
      ~[(perm-group-hook-poke [%associate pax [[pax %white] ~ ~]])]
    ==
  ::
  ++  contact-view-poke
    |=  act=[%create =path ships=(set ship)]
    ^-  card
    [%pass / %agent [our.bol %contact-view] %poke %contact-view-action !>(act)]
  ::
  ++  send-invite-poke
    |=  [=path =ship]
    ^-  card
    =/  =invite
      :*  our.bol  %chat-hook
          path  ship  ''
      ==
    =/  act=invite-action  [%invite /chat (shaf %msg-uid eny.bol) invite]
    [%pass / %agent [our.bol %invite-hook] %poke %invite-action !>(act)]
  ::
  ++  chat-scry
    |=  pax=path
    ^-  (unit mailbox)
    =.  pax  ;:(weld /=chat-store/(scot %da now.bol)/mailbox pax /noun)
    .^((unit mailbox) %gx pax)
  --
::
++  diff-chat-update
  |=  upd=chat-update
  ^-  (list card)
  =/  updates-json  (update-to-json upd)
  =/  configs-json  (configs-to-json configs-scry)
  :~  [%give %fact ~[/primary] %json !>(updates-json)]
      [%give %fact ~[/configs] %json !>(configs-json)]
  ==
::
::  +utilities
::
++  chat-poke
  |=  act=chat-action
  ^-  card
  [%pass / %agent [our.bol %chat-store] %poke %chat-action !>(act)]
::
++  group-poke
  |=  act=group-action
  ^-  card
  [%pass / %agent [our.bol %group-store] %poke %group-action !>(act)]
::
++  chat-hook-poke
  |=  act=chat-hook-action
  ^-  card
  [%pass / %agent [our.bol %chat-hook] %poke %chat-hook-action !>(act)]
::
++  permission-hook-poke
  |=  act=permission-hook-action
  ^-  card
  :*  %pass  /  %agent  [our.bol %permission-hook]
      %poke  %permission-hook-action  !>(act)
  ==
::
++  perm-group-hook-poke
  |=  act=permission-group-hook-action
  ^-  card
  :*  %pass  /  %agent  [our.bol %permission-group-hook]
      %poke  %permission-group-hook-action  !>(act)
  ==
::
++  envelope-scry
  |=  pax=path
  ^-  (list envelope)
  =.  pax  ;:(weld /=chat-store/(scot %da now.bol)/envelopes pax /noun)
  .^((list envelope) %gx pax)
::
++  configs-scry
  ^-  chat-configs
  .^(chat-configs %gx /=chat-store/(scot %da now.bol)/configs/noun)
::
++  group-scry
  |=  pax=path
  ^-  (unit group)
  .^((unit group) %gx ;:(weld /=group-store/(scot %da now.bol) pax /noun))
::
--
