::  /app/gora
::
::  %gora - a proof of presence protocol (sail version)
::    by quartus and the dalten collective
::
::  %gora has two versions in circulation:
::    ~laddys-dozzod-dalten (Vue.js frontend)
::    ~mister-dozzod-dalten (sail frontend)
::
::  %gora's sail version has moved to utilizing rudder,
::  by paldev. more here: https://github.com/Fang-/suite
::
::  %gora's user pokes include the following:
::
::  interacting with gora:
::  -  [%ignore-give @uv]
::    ignore gora @uv sent to u
::  -  [%accept-give @uv]
::    accept gora @uv sent to u
::  -  [%ignore-request @uv @p]
::    ignore request for gora @uv from @p
::  -  [%accept-request @uv @p]
::    accept request for gora @uv from @p
::  -  [%send-gora @uv (set ship)]
::    send gora @uv to (set ship)
::  -  [%send-plea @uv @p]
::    ask @p for gora @uv
::  -  [%kick ~]
::    maybe gora is naughty
::
::  making & changing gorae:
::  -  [%rm-gora @uv]
::    delete the gora with id=@uv
::  -  [%set-max @uv (unit @ud)]
::    set max allowed gorae
::  -  [%add-tag @tas (set id)]
::    add a tag to some gorae
::  -  [%rem-tag @tas (set id)]
::    remove a tag from some gorae
::  -  [%stak-em (set id) @t @t]
::    convert a set of gorae into a stak
::  -  [%set-pol @uv u?(%approve %decline)]
::    (un)set a gora's acceptance policy
::  -  [%mk-gora @t @t ?([%g hodl max] [%s stak])]
::    make a gora
::
::  %gora's scry endpoints include:
::    -  [%y %slam ~]
::      %slam integration
::    -  TBD
::
/-  *gora
/+  default-agent, dbug
::
|%
::
+$  card     card:agent:gall
+$  eyre-id  @ta
::
+$  versioned-state
  $%  state-2
      state-1
      state-0
  ==
:: state-2 structures
::
+$  state-2
  $:  %2
      =pita                                             ::  known gorae
      =public                                           ::  public gorae
      =policy                                           ::  gorae policies
      =logs                                             ::  logging information
      =tags                                             ::  tagging information
      =blacklist                                        ::  blocked gorae
  ==
+$  tag        @tas
+$  act        ?(%give %take %gack)
+$  tags       (jug tag id)
+$  pita       (map id gora)
+$  public     (set id)
+$  blacklist  (set id)
+$  logs                                                ::  activity log
  $:  offers=(set id)                                   ::  - incoming offers
      requests=(jug ship id)                            ::  - incoming requests
  ::                                                    ::   -and-
    $=  outgoing                                        ::  - outgoing actions
    (mip id [=ship =act] [wen=@da dun=(unit ?)])
  ==
+$  policy  (map id ?(%approve %decline))               ::  optional auto-action
:: old state structures
::
+$  state-1
  $:  %1
      =usps-mode  
      pita=pita-1
      =public     
      =request-log
      =offer-log  
      =blacklist
      =tag-set    
      =tags
      pend=(mip id [=ship =gib] [wen=@da dun=?])
  ==
::
+$  state-0
  $:  %0            
      pita=pita-0
      =request-log
      =offer-log
      =sent-log
      =blacklist
  ==
::
+$  tag-set      (set tag)
+$  sent-log     (jug id [ship ?(%ask %giv)])
+$  offer-log    (set id)
+$  usps-mode    ?
+$  request-log  (jug ship id)
+$  gib
  ?(%send-ask %send-giv %give-ack %chain-it %proxy-it)
::
+$  pita-1  (map id gora:one)
+$  pita-0  (map id gora:zero)
--
::
%-  agent:dbug
=|  state-2
=*  state  -
^-  agent:gall
=<
::!.
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)
    ak    ((on @da ,[id ship act (unit ?)]) gth)
::
++  on-init
  ^-  (quip card _this)
  %-  (slog leaf+"%gora -sail-start" ~)
  :_  this(state [%2 ~ ~ ~ [~ ~ ~] ~ ~])
  :~  =-  [%pass /eyre/connect %arvo %e -]
      [%connect [[~ [%apps %gora ~]] dap.bowl]]
  ::
      =-  [%pass /behn/suichi/(scot %da now.bowl) -]
      :+  %arvo  %b
  ::  XX replace: [%wait (add (sub now (mod now ~d1)) ~d1)]
      [%wait (add now.bowl ~m1)]
  ==
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  ole=vase
  |^  ^-  (quip card _this)
  =/  old=versioned-state  !<(versioned-state ole)
  =/  cards=(list card)
      :~  =-  [%pass /eyre/disconnect %arvo %e -]
          [%disconnect [~ [%apps %gora %public ~]]]
        ::
          =-  [%pass /eyre/connect %arvo %e -]
          [%connect [[~ [%apps %gora ~]] dap.bowl]]  
      ==
  =^  caz  old
    ?:(?=(%0 -.old) (from-0 old) [~ old])
  =^  coz  old
    ?:(?=(%1 -.old) (from-1 old) [~ old])
  ?>  ?=(%2 -.old)
  %-  (slog leaf+"%gora -sail-loaded" ~)
  [:(welp coz caz cards) this(state old)]
  ::
  ++  from-0
    |=  sta=state-0
    ^-  (quip card state-1)
    :-  ~ 
    :^    %1
        %.y
      %-  ~(run by pita.sta)
      |=  o=gora:zero
      ^-  gora:one
      :+  id.o  name.o
      [pic.o host.o made.o hodl.o %.n ~ %none %none]
    [~ request-log.sta offer-log.sta blacklist.sta ~ ~ ~]
  ::
  ++  from-1
    |=  sta=state-1
    ^-  (quip card state-2)
    =/  new-pita=_pita
      (mk-gora2 pita.sta)
    :-  :_  (weld pivot:subs:hc (gora:subs:hc new-pita))
        =-  [%pass /behn/suichi/(scot %da now.bowl) -]
        [%arvo %b [%wait (add now.bowl ~m1)]]
    :*  %2
        new-pita
        public.sta
        (mk-policy pita.sta)
        [offer-log.sta request-log.sta (mk-logs pend.sta)]
        tags.sta
        blacklist.sta
    ==
  ::
  ++  mk-gora2
    |=  p=pita-1
    |^  ^-  _pita
    %-  ~(run by p)
    |=  o=gora:one
    ^-  gora
    [%g id.o name.o pic.o host.o (to-da made.o) hodl.o max.o]
    ++  to-da
      |=  [y=@ud m=@ud d=@ud]
      (slav %da (crip "~{(a-co:co y)}.{<m>}.{<d>}"))
    --
  ::
  ++  mk-policy
    |=  p=pita-1
    ^-  _policy
    %-  ~(rep by p)
    |=  $:  [key=id val=gora:one]
            pol=(map id ?(%approve %decline))
        ==
    ?.  =(our.bowl host.val)  pol
    ?-  request-behavior.val
      %none     pol
      %reject   (~(put by pol) key %decline)
      %approve  (~(put by pol) key %approve)
    ==
  ::
  ++  mk-logs
    |=  p=(mip id [=ship =gib] [wen=@da dun=?])
    ^-  (mip id [ship act] [@da (unit ?)])
    =|  log=(mip id [ship act] [@da (unit ?)])
    =/  old=(list [i=id [s=ship g=gib] [w=@da d=?]])
      ~(tap bi p)
    |-  
    ?~  old  log
    %=    $
      old  t.old
    ::
        log
      ?+    g.i.old  log
          %send-ask
        %-  ~(put bi log)
        =,  i.old
        [i [s %take] [(sub w (mod w ~d1)) `d]]
      ::
          %send-giv
        %-  ~(put bi log)
        =,  i.old
        [i [s %give] [(sub w (mod w ~d1)) `d]]
      ::
          %give-ack
        %-  ~(put bi log)
        =,  i.old
        [i [s %gack] [(sub w (mod w ~d1)) `d]]
      ==
    ==
  --
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  =^  cards  state
    ?+    mark  (on-poke:def mark vase)
    ::    %gora-man-2 mark handled in helper core
    ::
        %gora-man-2
      ?>  =(our.bowl src.bowl)
      (manage:hc !<(manage-gora-2 vase))
    ::    %gora-transact-2, handle %gack, %offered, %request
    ::
        %gora-transact-2
      =/  tan=transact-2  !<(transact-2 vase)
      ?+    -.tan  (on-poke:def mark vase)
      ::    %gack - affirmatively acknowledge a give
      ::  - check that we have this gora
      ::  - check that we are the host
      ::  - check that we have a record of giving
      ::    this gora to that person
      ::
          %gack
        ?~  gor=(~(get by pita) id.tan)  !!
        ?>  =(our.bowl host.u.gor)
        ?>  %-  ~(has bi outgoing.logs)
            [id.tan [src.bowl %give]]
        ?-    -.u.gor
            %g
          ::  if the given gora is a standard gora,
          ::  - check that we're not above our max
          ::  - add to the set of hodl
          ::  - clear any requests for that gora
          ::  - set a policy if necessary
          ::  - send a card indicating the new holder
          ::
          ?>  ?~  max.u.gor  %.y
              (gth u.max.u.gor ~(wyt in hodl.u.gor))
          =/  new-hodl=(set ship)
            (~(put in hodl.u.gor) src.bowl)
          =.  pita
            %-  ~(put by pita)
            [id.u.gor u.gor(hodl new-hodl)]
          =?    requests.logs
              %-  ~(has ju requests.logs)
              [src.bowl id.u.gor]
            (~(del ju requests.logs) src.bowl id.u.gor)
          =?    policy
              ?~  max.u.gor  %.n
              =(u.max.u.gor +(~(wyt in hodl.u.gor)))
            (~(put by policy) id.tan %decline)            
          =/  pat=path
            /gora/(scot %uv id.u.gor)
          :_  state
          =-  [%give %fact ~[pat] %gora-transact-2 -]~
          !>  ^-  transact-2
          [%diff [%add-hodler (sy ~[src.bowl])]]
        ::
            %s
          ::  if the given gora is a stakable gora
          ::  - make sure they don't already have it
          ::    * giving a stakable only requires a gack
          ::      once. thereafter, its automatic
          ::  - add them to the stak
          ::  - clear any requests for that gora
          ::  - send a card indicating the new holder
          ::
          ?<  (~(has in ~(key by stak.u.gor)) src.bowl)
          =/  new-stak=stak
            (~(put by stak.u.gor) src.bowl 1)
          =.  pita
            %-  ~(put by pita)
            [id.u.gor u.gor(stak new-stak)]
          =?    requests.logs
              %-  ~(has ju requests.logs)
              [src.bowl id.u.gor]
            (~(del ju requests.logs) src.bowl id.u.gor)
          =/  pat=path
            /gora/(scot %uv id.u.gor)
          :_  state
          =-  [%give %fact ~[pat] %gora-transact-2 -]~
          !>  ^-  transact-2
          [%diff [%give-staks (my [src.bowl 1]~)]]
        ==
      ::    %offered - receive an offer of gora ownership
      ::  - if we don't have the gora, put it in
      ::  - if we aren't already owners, put it in offers
      ::  - run the sub function to sub to the gora
      ::
          %offered
        ?:  ?&  (~(has by pita) id.gora.tan)
                =(our.bol host.gora.tan)
                =(our.bol host:(~(got by pita) id.gora.tan))
            ==
          :-  ~
          %=    state
              pita
            ?-    -.gora.tan
                %g  
              %+  ~(put by pita)  id.gora.tan
              %=  gora.tan
                hodl  (~(put in hodl.gora.tan) our.bowl)
              ==
            ::
                %s
              %+  ~(put by pita)  id.gora.tan
              %=    gora.tan
                  stak
                ?~  had=(~(get by stak.gora.tan) our.bowl)
                  (~(put by stak.gora.tan) our.bowl 1)
                (~(put by stak.gora.tan) [our.bowl u.had])
              ==
            ==
          ==
        ?>  =(host.gora.tan src.bowl)
        ?-   -.gora.tan
            %g
          :-  (gora:subs:hc pita)
          %=    state
              offers.logs
            ?:  (~(has in hodl.gora.tan) our.bowl)
              offers.logs
            (~(put in offers.logs) id.gora.tan)
          ::
              pita
            ?~  go=(~(get by pita) id.gora.tan)
              (~(put by pita) id.gora.tan gora.tan)
            ?>  =(host.u.go src.bowl)
            (~(put by pita) id.gora.tan gora.tan)
          ==
        ::
            %s
          :-  (gora:subs:hc pita)
          %=    state
              offers.logs
            ?:  (~(has in ~(key by stak.gora.tan)) our.bowl)
              offers.logs
            (~(put in offers.logs) id.gora.tan)
          ::
              pita
            ?^  nul.gora.tan
              %-  ~(put by (rm-nul:shim:hc u.nul.gora.tan))
              [id.gora.tan gora.tan]
            ?~  go=(~(get by pita) id.gora.tan)
              (~(put by pita) id.gora.tan gora.tan)
            ?>  =(host.u.go src.bowl)
            (~(put by pita) id.gora.tan gora.tan)
          ==
        ==
      ::
          %request
        ?~  gor=(~(get by pita) id.tan)  !!
        ?>  =(our.bowl host.u.gor)
        =/  pat=path
          /gora/(scot %uv id.tan)/(scot %p host.u.gor)
        ?-    -.u.gor
            %g
          ?~  pol=(~(get by policy) id.tan)
            ?:  (~(has in hodl.u.gor) src.bowl)
              :_  state
              =-  [%give %fact ~[pat] %gora-transact-2 -]~
              !>  ^-  transact-2
              [%diff [%add-hodler (sy ~[src.bowl])]]
            =.  requests.logs
                (~(put ju requests.logs) src.bowl id.tan)
            `state
          ?-    u.pol
            %decline  !!
          ::
              %approve
            =?    policy
                ?~  max.u.gor  %.n
                =(u.max.u.gor +(~(wyt in hodl.u.gor)))
              (~(put by policy) id.tan %decline)
            =.  pita
              %+  ~(put by pita)  id.tan
              u.gor(hodl (~(put in hodl.u.gor) src.bowl))
            =.  requests.logs
              (~(del ju requests.logs) src.bowl id.tan)
            `state
          ==
          
        ::
            %s
          ?~  had=(~(get by stak.u.gor) src.bowl)
            =.  requests.logs
              (~(put ju requests.logs) src.bowl id.u.gor)
            `state
          :_  state
          =-  [%give %fact ~[pat] %gora-transact-2 -]~
          !>  ^-  transact-2
          [%diff [%give-staks (my [src.bowl u.had]~)]]
        ==
      ==
    ==
  [cards this]
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?:  ?=([%update @ ~] path)
    =/  id=@uv  (slav %uv i.t.path)
    ?~  gor=(~(get by pita) id)  !!
    ?>  &(?=(%g -.u.gor) =(our.bowl host.u.gor))
    =/  g=gora:one
      :^  id.u.gor  name.u.gor  pic.u.gor
      :+  host.u.gor
        =+((yore now.bowl) [y.- m.- d.t.-])
      [hodl.u.gor %.n max.u.gor %none %none]
    :_  this
    :~  =-  [%give %fact ~ %gora-transact-1 -]
        !>(`transact-1:one`[%update %upd `[%initialize g]])
      ::
        [%give %kick ~ ~]
    ==
  ?.  ?=([%gora @ ~] path)  (on-watch:def path)
  ~_  :-  %leaf
      """
      %gora -bad-sub
      > id: {(trip i.t.path)}
      > from: {(scow %p src.bowl)}
      """
  =/  id=@uv  (slav %uv i.t.path)
  ?~  gor=(~(get by pita) id)  !!
  ?>  =(our.bowl host.u.gor)
  :_  this
  =-  [%give %fact ~ [%gora-transact-2 -]]~
  ?-    -.u.gor
      %g
    !>(`transact-2`[%diff [%start-gora +.u.gor]])
  ::
      %s
    !>(`transact-2`[%diff [%start-stak +.u.gor]])
  ==
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+   wire  (on-arvo:def wire sign-arvo)
      [%eyre %connect ~]
    ?+  sign-arvo  (on-arvo:def wire sign-arvo)
        [%eyre %bound *]
      ~?  !accepted.sign-arvo
        [dap.bowl [%eyre %bind %fail] binding.sign-arvo]
      `this
    ==
  ::
      [%behn %suichi @ ~]
    ?+  sign-arvo  (on-arvo:def wire sign-arvo)
        [%behn %wake *]
      ?~  error.sign-arvo
        ~&  >  [%behn %suichi ~]
        :_  this
        ;:  welp
          (gora:subs:hc pita)
          =-  [%pass /behn/suichi/(scot %da now.bowl) -]~
          [%arvo %b [%wait (add now.bowl ~m1)]]
        ==
      ~&  >>  [%behn %suichi error.sign-arvo]
      :_  this
      =-  [%pass /behn/suichi/(scot %da now.bowl) -]~
      [%arvo %b [%wait (add now.bowl ~m1)]]
    ==
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%updates @ ~]
    :_  this
    [%pass wire %agent [src.bowl %gora] %leave ~]~
  ::
        [%allow @ @ ~]
    =/  id=@uv   (slav %uv i.t.wire)
    =/  hu=ship  (slav %p i.t.t.wire)
    ?.  ?=(%poke-ack -.sign)  (on-agent:def wire sign)
    ?~  got=(~(get bi outgoing.logs) id [hu %gack])
      ~_  leaf+"%gora -missing-offer-for-ack"  !!
    =.  outgoing.logs
      %+  ~(put bi:mip outgoing.logs)  id
      [[hu %gack] [-.u.got `?=(~ p.sign)]]
    `this
  ::
      [%offer @ @ ~]
    =/  id=@uv   (slav %uv i.t.wire)
    =/  hu=ship  (slav %p i.t.t.wire)
    ?.  ?=(%poke-ack -.sign)  (on-agent:def wire sign)
    ?~  got=(~(get bi outgoing.logs) id [hu %give])
      ~_  leaf+"%gora -missing-offer-for-ack"  !!
    =.  outgoing.logs
      %+  ~(put bi:mip outgoing.logs)  id
      [[hu %give] [-.u.got `?=(~ p.sign)]]
    `this
  ::
      [%plead @ @ ~]
    =/  id=@uv   (slav %uv i.t.wire)
    =/  hu=ship  (slav %p i.t.t.wire)
    ?.  ?=(%poke-ack -.sign)  (on-agent:def wire sign)
    ?~  got=(~(get bi outgoing.logs) id [hu %take])
      ~_  leaf+"%gora -missing-plead-for-ack"  !!
    =.  outgoing.logs
      %+  ~(put bi:mip outgoing.logs)  id
      [[hu %take] [-.u.got `?=(~ p.sign)]]
    `this
  ::
      [%gora @ @ ~]
    =/  id=@uv   (slav %uv i.t.wire)
    =/  ho=ship  (slav %p i.t.t.wire)
    ?~  gor=(~(get by pita) id)
      ?+    sign  !!
      ::
          [%kick ~]
        :_  this
        =-  [%pass wire %agent [src.bowl %gora] -]~
        [%watch [%gora i.t.wire ~]]
      ::
          [%watch-ack *]
        ?~  p.sign  `this
        %.  `this
        (slog leaf+"%gora -watch-nack-580 {<id>}" ~)
      ::
          [%fact %gora-transact-2 *]
        =/  tan=transact-2
          !<(transact-2 q.cage.sign)
        ?+    tan  ~_  leaf+"%gora -strange-exit"  !!
            [%diff %start-stak *]
          ?>  ?&  (gte 32.768 (met 3 pic.diff.tan))
                  =(src.bowl host.diff.tan)
              ==
          ?~  nul.diff.tan
            =?    offers.logs
                ?&  (~(has in offers.logs) id.diff.tan)
                ::
                    %.  our.bowl
                    ~(has in ~(key by stak.diff.tan))
                ==
              (~(del in offers.logs) id.diff.tan)
            =.  pita
              (~(put by pita) id.diff.tan [%s +.diff.tan])
            `this
            ::
          ?>  %+  levy  u.nul.diff.tan
              |=(g=gora =(src.bowl host.g))
          =/  ids=(set @uv)
            (sy (turn u.nul.diff.tan |=(g=[%g i=@uv *] i.g)))
          =?    offers.logs
              ?&  (~(has in offers.logs) id.diff.tan)
                  %.  our.bowl
                  ~(has in ~(key by stak.diff.tan))
              ==
            (~(del in offers.logs) id.diff.tan)
          =.  pita
            %.  [id.diff.tan [%s +.diff.tan]]
            %~  put  by
            ^-  _pita
            %-  ~(rep by pita)
            |=  [[k=^id v=gora] r=_pita]
            ?:((~(has in ids) k) r (~(put by r) k v))
          `this
        ::
            [%diff %start-gora *]
          ?>  ?&  ?~  max.diff.tan  %.y
                  %+  gte  u.max.diff.tan
                  ~(wyt in hodl.diff.tan)
                ::
                  (gte 32.768 (met 3 pic.diff.tan))
                  =(src.bowl host.diff.tan)
              ==
          =?    offers.logs
              ?&  (~(has in offers.logs) id.diff.tan)
                  (~(has in hodl.diff.tan) our.bowl)
              ==
            (~(del in offers.logs) id.diff.tan)
          =.  pita
            (~(put by pita) id.diff.tan [%g +.diff.tan])
          `this
        ==
      ==
      ::
    ?.  =(host.u.gor src.bowl)
      :_  this
      [%pass wire %agent [src.bowl %gora] %leave ~]~
    ?+    sign  (on-agent:def wire sign)
        [%kick ~]
      :_  this
      =-  [%pass wire %agent [src.bowl %gora] -]~
      [%watch [%gora i.t.wire ~]]
    ::
        [%watch-ack *]
      ?~  p.sign  `this
      ~&  >  "651"
      =-  ((slog leaf+- ~) `this)
      """
      %gora -watch-nack {<id.u.gor>}
            -{<host.u.gor>}-version-mismatch}
      """
    ::
        [%fact %gora-transact-1 *]
      =/  tan=transact-1:one
        !<(transact-1:one q.cage.sign)
      ?+    -.tan  `this
          %update
        ?-    act.tan
          %del  `this(pita (~(del by pita) id))
        ::
            %upd
          ?~  jot.tan  `this
          ?.  ?=(%new-hodlr -.u.jot.tan)  `this
          ?.  ?=(%g -.u.gor)  `this
          =.  pita
            %+  ~(put by pita)  id.u.gor
            u.gor(hodl (~(put in hodl.u.gor) ship.u.jot.tan))
          `this
        ==  
      ==
    ::
        [%fact %gora-transact-2 *]
      =/  tan=transact-2
        !<(transact-2 q.cage.sign)
      ?>  ?=(%diff -.tan)
      ?-    -.diff.tan
          %illustrate
        ?~  gor=(~(get by pita) id)
          :_  this
          [%pass wire %agent [src.bowl %gora] %leave ~]~
        =.  pita
          %+  ~(put by pita)
            id.u.gor
          u.gor(pic new.diff.tan)
        `this
          %change-max
        ?>  ?=(%g -.u.gor)
        ?~  max.diff.tan
          =.  pita
            %-  ~(put by pita)
            [id.u.gor u.gor(max max.diff.tan)]
          `this
        ?>  (gte u.max.diff.tan ~(wyt in hodl.u.gor))
        =.  pita
          %-  ~(put by pita)
          [id.u.gor u.gor(max max.diff.tan)]
        `this
          %give-staks
        ?>  ?=(%s -.u.gor)
        =?    offers.logs
            ?&  (~(has in offers.logs) id.u.gor)
            ::
                %.  our.bowl
                ~(has in ~(key by new.diff.tan))
            ==
          (~(del in offers.logs) id.u.gor)
        =.  pita
          %+  ~(put by pita)  id.u.gor
          u.gor(stak (~(uni by stak.u.gor) new.diff.tan))
        `this
          %add-hodler
        ?>  ?=(%g -.u.gor)
        =?    offers.logs
            ?&  (~(has in offers.logs) id.u.gor)
                (~(has in new.diff.tan) our.bowl)
            ==
          (~(del in offers.logs) id.u.gor)
        =.  pita
          %+  ~(put by pita)  id.u.gor
          u.gor(hodl (~(uni in hodl.u.gor) new.diff.tan))
        `this
      ::
          %start-stak
        `this
      ::
          %start-gora
        `this
      ::
          %deleted-me
        =.  pita
          (~(del by pita) id)
        `this
      ==
    ==
  ==
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+    path  (on-peek:def path)
       [%y %slam ~]
    =-  ``noun+!>(`(list [@t @t @p])`-)
    %-  ~(rep by pita)
    |=  [[@uv g=gora] l=(list [@t @t @p])]
    ?-    -.g
        %g
      ?.  (~(has in hodl.g) our.bowl)  l
      [[name.g pic.g host.g] l]
    ::
        %s
      ?.  (~(has in ~(key by stak.g)) our.bowl)  l
      [[name.g pic.g host.g] l]
    ==
  ::
      [%x %offers ~]
    ?>  (team:title our.bowl src.bowl)
    =-  ``json+!>(`json`a+-)
    (turn ~(tap in offers.logs) |=(o=@uv s+(scot %uv o)))
  ::
      [%x %requests @ ~]
    ?>  (team:title our.bowl src.bowl)
    =-  ``json+!>(`json`a+-)
    %+  turn
      %~  tap  in
      (~(get ju requests.logs) (slav %p i.t.t.path))
    |=(o=@uv s+(scot %uv o))
  ::
      [%x %tags ~]
    ?>  (team:title our.bowl src.bowl)
    =-  ``json+!>(`json`a+-)
    (turn ~(tap in ~(key by tags)) |=(t=@tas s+t))
  ::
      [%x %made-gora ~]
    ?>  (team:title our.bowl src.bowl)
    =-  ``noun+!>(`(set gora)`-)
    %-  ~(rep by pita)
    |=  [[k=id v=gora] s=(set gora)]
    ?.(=(our.bowl host.v) s (~(put in s) v))
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
::
|_  bol=bowl:gall
++  shim
  |%
  ++  id-stk
    |=  [n=name h=host p=pic r=[s=stak n=nul] m=@da]
    (sham n h p r m)
  ++  id-stn
    |=  [n=name h=host p=pic r=[h=hodl m=max] m=@da]
    (sham n h p r m)
  ++  rm-nul
    |=  l=(list gora-standard)
    ^-  _pita
    |-  ?~  l  pita
    %=  $
      l     t.l
      pita  (~(del by pita) id.i.l)
    ==
  --
++  subs
  |%
  ++  pivot
    ^-  (list card)
    %-  ~(rep by wex.bol)
    |=  $:  [[w=wire h=ship t=term] [a=? p=path]]
            o=(list card)
        ==
    ?.  &(=(%gora t) !?=([%gora @ @ ~] w))  o
    [[%pass w %agent [h %gora] %leave ~] o]
  ++  paths
    ^-  (set path)
    %-  ~(rep by wex.bol)
    |=  $:  [[w=wire h=ship t=term] [a=? p=path]]
            o=(set path)
        ==
    ?.  ?&  =(%gora t)
            ?=([%gora @ @ ~] w)
            |(?=([%updates @ ~] p) ?=([%gora @ ~] p))
        ==
      o
    ?.(a o (~(put in o) [%gora +.p]))
  ++  gora
    |=  p=_pita
    =+  pat=paths
    ^-  (list card)
    %+  murn  ~(tap by p)
    |=  [i=id g=^gora]
    ?:  =(our.bol host.g)  ~
    ?:  (~(has in pat) [%gora (scot %uv i) ~])  ~
    :-  ~
    :+  %pass  /gora/(scot %uv i)/(scot %p host.g)
    [%agent [host.g %gora] %watch [%gora (scot %uv i) ~]]
  --
++  manage
  |=  man=manage-gora-2
  |^  ^-  (quip card _state)
  ?-    -.man
      $?  %rm-gora
          %set-max
          %add-tag
          %rem-tag
          %stak-em
          %set-pol
          %mk-gora
      ==
    (g-hand man)
  ::
      %ignore-give
    ?>  (~(has in offers.logs) id.man)
    ?~  gor=(~(get by pita) id.man)
      `state(offers.logs (~(del in offers.logs) id.man))
    =.  pita
      (~(del by pita) id.man)
    `state(offers.logs (~(del in offers.logs) id.man))
  ::
      %accept-give
    ?>  (~(has in offers.logs) id.man)
    ?~  gor=(~(get by pita) id.man)
      `state(offers.logs (~(del in offers.logs) id.man))
    =.  outgoing.logs
      %+  ~(put bi outgoing.logs)  id.man
      [[host.u.gor %gack] [now.bol ~]]
    =/  wir=path
      /allow/(scot %uv id.man)/(scot %p host.u.gor)
    :_  state(offers.logs (~(del in offers.logs) id.man))
    =-  [%pass wir %agent [host.u.gor %gora] %poke -]~
    [%gora-transact-2 !>(`transact-2`[%gack id.man])]
  ::
      %ignore-request
    ?>  (~(has ju requests.logs) ship.man id.man)
    ?~  gor=(~(get by pita) id.man)
      =.  requests.logs
        %-  ~(rep by requests.logs)
        |=  [[k=ship v=(set id)] r=(jug ship id)]
        ?.  (~(has in v) id.man)  (~(put by r) k v)
        (~(put by r) k (~(del in v) id.man))
      `state
    =.  requests.logs
      (~(del ju requests.logs) ship.man id.man)
    `state
      %accept-request
    ?>  (~(has ju requests.logs) ship.man id.man)
    ?~  gor=(~(get by pita) id.man)
      =.  requests.logs
        %-  ~(rep by requests.logs)
        |=  [[k=ship v=(set id)] r=(jug ship id)]
        ?.  (~(has in v) id.man)  (~(put by r) k v)
        (~(put by r) k (~(del in v) id.man))
      `state
    ?-  -.u.gor
        %g
      ?~  max.u.gor
        =.  requests.logs
          (~(del ju requests.logs) ship.man id.man)
        =.  pita
          %+  ~(put by pita)  id.u.gor
          u.gor(hodl (~(put in hodl.u.gor) ship.man))
        =/  pat=path
          /gora/(scot %uv id.u.gor)
        :_  state
        =-  [%give %fact ~[pat] %gora-transact-2 -]~
        !>  ^-  transact-2
        [%diff [%add-hodler (sy ~[ship.man])]]
      ?>  (gth u.max.u.gor ~(wyt in hodl.u.gor))
      =.  requests.logs
        ?.  =(u.max.u.gor +(~(wyt in hodl.u.gor)))
          (~(del ju requests.logs) ship.man id.u.gor)
        %-  ~(rep by requests.logs)
        |=  [[k=ship v=(set id)] r=(jug ship id)]
        ?.  (~(has in v) id.man)  (~(put by r) k v)
        (~(put by r) k (~(del in v) id.man))
      =?    policy
          =(u.max.u.gor +(~(wyt in hodl.u.gor)))
        (~(put by policy) id.u.gor %decline)
      =.  pita
        %+  ~(put by pita)  id.u.gor
        u.gor(hodl (~(put in hodl.u.gor) ship.man))
      =/  pat=path
        /gora/(scot %uv id.u.gor)
      :_  state
      =-  [%give %fact ~[pat] %gora-transact-2 -]~
      !>  ^-  transact-2
      [%diff [%add-hodler (sy ~[ship.man])]]
    ::
        %s
      =/  sats=@ud
        ?~  had=(~(get by stak.u.gor) ship.man)
        1  +(u.had)
      =.  requests.logs
        (~(del ju requests.logs) ship.man id.u.gor)
      =.  pita
        %+  ~(put by pita)  id.u.gor
        u.gor(stak (~(put by stak.u.gor) ship.man sats))
      =/  pat=path
        /gora/(scot %uv id.u.gor)
      :_  state
      =-  [%give %fact ~[pat] %gora-transact-2 -]~
      !>  ^-  transact-2
      [%diff [%give-staks (my [ship.man sats]~)]]
    ==
  ::
      %send-gora
    ?~  gor=(~(get by pita) id.man)  !!
    ?>  =(our.bol host.u.gor)
    ?:  =(~ who.man)  !!
    ?-    -.u.gor
        %g
      =;  [offers=(list card) legs=_outgoing.logs]
        :_  state(outgoing.logs legs)
        ?:  =(who.man (~(dif in who.man) hodl.u.gor))
          offers
        :_  offers
        ^-  card
        =-  [%give %fact ~[/gora/(scot %uv id.u.gor)] -]
        :-  %gora-transact-2
        !>(`transact-2`[%diff [%add-hodler hodl.u.gor]])
      %-  ~(rep in (~(dif in who.man) hodl.u.gor))
      |=  [s=ship [p=(list card) q=_outgoing.logs]]
      :_  (~(put bi q) id.u.gor [s %give] [now.bol ~])
      :_  p
      ^-  card
      =/  wir=path
        /offer/(scot %uv id.u.gor)/(scot %p s)
      =-  [%pass wir %agent [s %gora] %poke -]
      :-  %gora-transact-2
      !>(`transact-2`[%offered u.gor])
    ::
        %s
      =;  [offers=(list card) stik=stak legs=_outgoing.logs]
        :-  :_  offers
            =-  [%give %fact ~[/gora/(scot %uv id.u.gor)] -]
            :-  %gora-transact-2
            !>  ^-  transact-2
            [%diff [%give-staks (~(dif in stik) stak.u.gor)]]
        %=  state
          outgoing.logs  legs
        ::
            pita
          (~(put by pita) id.u.gor u.gor(stak stik))
        ==
      %-  ~(rep in who.man)
      |=  [s=ship [p=(list card) q=_stak.u.gor r=_outgoing.logs]]
      ?~  had=(~(get by stak.u.gor) s)
        =/  wir=path
          /offer/(scot %uv id.u.gor)/(scot %p s)
        :+  :_  p
            ^-  card
            =-  [%pass wir %agent [s %gora] %poke -]
            :-  %gora-transact-2
            !>(`transact-2`[%offered u.gor])
          q
        (~(put bi r) id.u.gor [s %give] [now.bol ~])
      :+  p
        (~(put by q) [s +(u.had)])
      (~(put bi r) id.u.gor [s %give] [now.bol ~])
    ==
  ::
      %send-plea
    =/  wir=path
      /plead/(scot %uv id.man)/(scot %p host.man)
    =.  outgoing.logs
      %^  ~(put bi outgoing.logs)  id.man
      [host.man %take]  [now.bol ~]
    :_  state
    =-  [%pass wir %agent [host.man %gora] %poke -]~
    [%gora-transact-2 !>(`transact-2`[%request id.man])]
  ::
      %kick
    %-  (slog leaf+"%gora -ouch" ~)
    [(gora:subs pita) state]
  ==
  ++  g-hand
    |=  gal=gora-handle
    ^-  (quip card _state)
    ?-    -.gal
        %rm-gora
      ~_  "%gora -rm-{<id.gal>}-gora-not-found"
      =/  gor=gora
        (~(got by pita) id.gal)
      ?.  =(our.bol host.gor)
        =/  wir=path
          /gora/(scot %uv id.gal)/(scot %p host.gor)
        :_  state(pita (~(del by pita) id.gal))
        [%pass wir %agent [host.gor %gora] %leave ~]~
      =/  pat=path
        /gora/(scot %uv id.gal)
      :_  state(pita (~(del by pita) id.gal))
      =-  [%give %fact ~[pat] %gora-transact-2 -]~
      !>(`transact-2`[%diff [%deleted-me ~]])
    ::
        %set-max
      ~_  "%gora -set-max-{<id.gal>}-failed"
      =/  gor=gora
        (~(got by pita) id.gal)
      ?>  ?=(%g -.gor)
      ?>  =(our.bol host.gor)
      =/  pat=path
        /gora/(scot %uv id.gal)
      ?~  max.gor
        ?~  max.gal  `state
        ?>  (gte u.max.gal ~(wyt in hodl.gor))
        =.  pita
          (~(put by pita) id.gor gor(max max.gal))
        :_  state
        =-  [%give %fact ~[pat] %gora-transact-2 -]~
        !>(`transact-2`[%diff [%change-max max.gal]])
        ::
      ?~  max.gal
        =.  pita
          (~(put by pita) id.gor gor(max max.gal))
        :_  state
        =-  [%give %fact ~[pat] %gora-transact-2 -]~
        !>(`transact-2`[%diff [%change-max max.gal]])
        ::
      ?>  (gth u.max.gal u.max.gor)
      =.  pita
        (~(put by pita) id.gor gor(max max.gal))
      :_  state
      =-  [%give %fact ~[pat] %gora-transact-2 -]~
      !>(`transact-2`[%diff [%change-max max.gal]])
    ::
        %add-tag
      `state
    ::
        %rem-tag
      `state
    ::
        %stak-em
      ~_  '%gora -stak-em-failed'
      |^
      ?.  ?=(%.y -.which.gal)
        =^  [caz=(list card) goz=(list gora-standard)]  dez.gal
          ^-  [(pair (list card) (list gora-standard)) (set id)]
          (rm-gor dez.gal)
          ::
        ?<  ?=(~ goz)
        =/  stik=stak
          +:((mk-stk ~) dez.gal)
          ::
        =/  new=gora-stakable
          =-  :^  %s  -  -.p.which.gal
              :+  +.p.which.gal  our.bol
              [(sub now.bol (mod now.bol ~d1)) stik `goz]
          %-  id-stk:shim
          :^  -.p.which.gal  our.bol  +.p.which.gal
          [[stik `goz] (sub now.bol (mod now.bol ~d1))]
          ::

        :-  (weld caz (mk-coz ~(key by stak.new) id.new new))
        %=  state
          pita           (~(put by (rm-nul:shim goz)) id.new new)
          outgoing.logs  (ch-log ~(key by stak.new) id.new)
        ==
        ::
      =/  ole=[s=stak g=gora-stakable]
        (ck-stk p.which.gal)
        ::
      =^  [caz=(list card) goz=(list gora-standard)]  dez.gal
        ^-  [(pair (list card) (list gora-standard)) (set id)]
        (rm-gor dez.gal)
        ::
      ?<  ?=(~ goz)
      =^  new  stak.g.ole
        ^-  [(set ship) stak]
        ((mk-stk stak.g.ole) dez.gal)
        ::
      :-  %+  weld  caz
          =-  (mk-coz - id.g.ole g.ole)
          (~(dif in new) ~(key by s.ole))
      %=    state
          pita
        %+  ~(put by (rm-nul:shim goz))  id.g.ole
        %=    g.ole
            nul
          ?~(nul.g.ole [~ goz] `(weld u.nul.g.ole goz))
        ==
      ::
          outgoing.logs
        (ch-log (~(dif in new) ~(key by s.ole)) id.g.ole)
      ==
      ::
      ++  ck-stk
        |=  i=id
        ^-  [stak gora-stakable]
        =-  ?>(?=(%s -.-) [stak.- -])
        (~(got by pita) i)
      ::
      ++  mk-coz
        |=  [s=(set ship) i=id g=gora]
        ^-  (list card)
        %+  turn  ~(tap in s)
        |=  who=@p
        =/  wir=path
          /offer/(scot %uv i)/(scot %p who)
        ^-  card
        =-  [%pass wir %agent [who %gora] %poke -]
        [%gora-transact-2 !>(`transact-2`[%offered g])]
      ::
      ++  ch-log
        |=  [s=(set ship) i=id]
        %-  ~(rep in s)
        |=  [p=ship q=_outgoing.logs]
        (~(put bi q) [i [[p %give] [now.bol ~]]])
      ::
      ++  mk-stk
        |=  s-t=stak
        |=  s-i=(set id)
        ^-  [(set ship) stak]
        =-  [~(key by -) -]
        %-  ~(uni by s-t)
        ^-  stak
        %-  ~(rep in s-i)
        |=  [i=id s=_s-t]
        =+  gor=(~(got by pita) i)
        ?>  &(?=(%g -.gor) =(our.bol host.gor))
        %-  ~(uni by s)
        ^-  stak
        %-  ~(rep in hodl.gor)
        |=  [p=ship q=_s]
        ~&  >  [%p p %q q]
        ?~  had=(~(get by q) p)
          ~&  >>  [%p %get %one]
          (~(put by q) p 1)
        ~&  >>>  [%p %add %one +(u.had)]
        (~(put by q) p +(u.had))
      ::
      ++  rm-gor
        |=  s-i=(set id)
        ^-  [(pair (list card) (list gora-standard)) (set id)]
        %-  ~(rep in s-i)
        |=  $:  i=id
            ::
              $:  (pair (list card) (list gora-standard))
                  r=(set id)
              ==
            ==
        ?~  gor=(~(get by pita) i)  [[p q] r]
        ?.  &(?=(%g -.u.gor) =(our.bol host.u.gor))
          [[p q] r]
        =/  pat=path
          /gora/(scot %uv id.u.gor)
        =-  [[- [u.gor q]] (~(put in r) id.u.gor)]
        ^-  (list card)
        :_  p
        =-  [%give %fact ~[pat] %gora-transact-2 -]
        !>(`transact-2`[%diff [%deleted-me ~]])
      --
    ::
        %set-pol
      `state
    ::
        %mk-gora
      `state
    ::
    ==
  --
--