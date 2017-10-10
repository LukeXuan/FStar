open Prims
type name = FStar_Syntax_Syntax.bv[@@deriving show]
type env = FStar_TypeChecker_Env.env[@@deriving show]
type implicits = FStar_TypeChecker_Env.implicits[@@deriving show]
let normalize:
  FStar_TypeChecker_Normalize.step Prims.list ->
    FStar_TypeChecker_Env.env ->
      FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term
  =
  fun s  ->
    fun e  ->
      fun t  ->
        FStar_TypeChecker_Normalize.normalize_with_primitive_steps
          FStar_Reflection_Interpreter.reflection_primops s e t
let bnorm:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term
  = fun e  -> fun t  -> normalize [] e t
type 'a tac =
  {
  tac_f: FStar_Tactics_Types.proofstate -> 'a FStar_Tactics_Result.__result;}
[@@deriving show]
let __proj__Mktac__item__tac_f:
  'a .
    'a tac ->
      FStar_Tactics_Types.proofstate -> 'a FStar_Tactics_Result.__result
  =
  fun projectee  ->
    match projectee with | { tac_f = __fname__tac_f;_} -> __fname__tac_f
let mk_tac:
  'a .
    (FStar_Tactics_Types.proofstate -> 'a FStar_Tactics_Result.__result) ->
      'a tac
  = fun f  -> { tac_f = f }
let run:
  'Auu____88 .
    'Auu____88 tac ->
      FStar_Tactics_Types.proofstate ->
        'Auu____88 FStar_Tactics_Result.__result
  = fun t  -> fun p  -> t.tac_f p
let ret: 'a . 'a -> 'a tac =
  fun x  -> mk_tac (fun p  -> FStar_Tactics_Result.Success (x, p))
let bind: 'a 'b . 'a tac -> ('a -> 'b tac) -> 'b tac =
  fun t1  ->
    fun t2  ->
      mk_tac
        (fun p  ->
           let uu____155 = run t1 p in
           match uu____155 with
           | FStar_Tactics_Result.Success (a,q) ->
               let uu____162 = t2 a in run uu____162 q
           | FStar_Tactics_Result.Failed (msg,q) ->
               FStar_Tactics_Result.Failed (msg, q))
let idtac: Prims.unit tac = ret ()
let goal_to_string: FStar_Tactics_Types.goal -> Prims.string =
  fun g  ->
    let g_binders =
      let uu____174 =
        FStar_TypeChecker_Env.all_binders g.FStar_Tactics_Types.context in
      FStar_All.pipe_right uu____174
        (FStar_Syntax_Print.binders_to_string ", ") in
    let w = bnorm g.FStar_Tactics_Types.context g.FStar_Tactics_Types.witness in
    let t = bnorm g.FStar_Tactics_Types.context g.FStar_Tactics_Types.goal_ty in
    let uu____177 =
      FStar_TypeChecker_Normalize.term_to_string
        g.FStar_Tactics_Types.context w in
    let uu____178 =
      FStar_TypeChecker_Normalize.term_to_string
        g.FStar_Tactics_Types.context t in
    FStar_Util.format3 "%s |- %s : %s" g_binders uu____177 uu____178
let tacprint: Prims.string -> Prims.unit =
  fun s  -> FStar_Util.print1 "TAC>> %s\n" s
let tacprint1: Prims.string -> Prims.string -> Prims.unit =
  fun s  ->
    fun x  ->
      let uu____191 = FStar_Util.format1 s x in
      FStar_Util.print1 "TAC>> %s\n" uu____191
let tacprint2: Prims.string -> Prims.string -> Prims.string -> Prims.unit =
  fun s  ->
    fun x  ->
      fun y  ->
        let uu____204 = FStar_Util.format2 s x y in
        FStar_Util.print1 "TAC>> %s\n" uu____204
let tacprint3:
  Prims.string -> Prims.string -> Prims.string -> Prims.string -> Prims.unit
  =
  fun s  ->
    fun x  ->
      fun y  ->
        fun z  ->
          let uu____221 = FStar_Util.format3 s x y z in
          FStar_Util.print1 "TAC>> %s\n" uu____221
let comp_to_typ: FStar_Syntax_Syntax.comp -> FStar_Syntax_Syntax.typ =
  fun c  ->
    match c.FStar_Syntax_Syntax.n with
    | FStar_Syntax_Syntax.Total (t,uu____227) -> t
    | FStar_Syntax_Syntax.GTotal (t,uu____237) -> t
    | FStar_Syntax_Syntax.Comp ct -> ct.FStar_Syntax_Syntax.result_typ
let is_irrelevant: FStar_Tactics_Types.goal -> Prims.bool =
  fun g  ->
    let uu____251 =
      let uu____256 =
        FStar_TypeChecker_Normalize.unfold_whnf g.FStar_Tactics_Types.context
          g.FStar_Tactics_Types.goal_ty in
      FStar_Syntax_Util.un_squash uu____256 in
    match uu____251 with
    | FStar_Pervasives_Native.Some t -> true
    | uu____262 -> false
let dump_goal:
  'Auu____273 . 'Auu____273 -> FStar_Tactics_Types.goal -> Prims.unit =
  fun ps  ->
    fun goal  -> let uu____283 = goal_to_string goal in tacprint uu____283
let dump_cur: FStar_Tactics_Types.proofstate -> Prims.string -> Prims.unit =
  fun ps  ->
    fun msg  ->
      match ps.FStar_Tactics_Types.goals with
      | [] -> tacprint1 "No more goals (%s)" msg
      | h::uu____293 ->
          (tacprint1 "Current goal (%s):" msg;
           (let uu____297 = FStar_List.hd ps.FStar_Tactics_Types.goals in
            dump_goal ps uu____297))
let ps_to_string:
  (Prims.string,FStar_Tactics_Types.proofstate)
    FStar_Pervasives_Native.tuple2 -> Prims.string
  =
  fun uu____305  ->
    match uu____305 with
    | (msg,ps) ->
        let uu____312 = FStar_Util.string_of_int ps.FStar_Tactics_Types.depth in
        let uu____313 =
          FStar_Util.string_of_int
            (FStar_List.length ps.FStar_Tactics_Types.goals) in
        let uu____314 =
          let uu____315 =
            FStar_List.map goal_to_string ps.FStar_Tactics_Types.goals in
          FStar_String.concat "\n" uu____315 in
        let uu____318 =
          FStar_Util.string_of_int
            (FStar_List.length ps.FStar_Tactics_Types.smt_goals) in
        let uu____319 =
          let uu____320 =
            FStar_List.map goal_to_string ps.FStar_Tactics_Types.smt_goals in
          FStar_String.concat "\n" uu____320 in
        FStar_Util.format6
          "State dump @ depth %s(%s):\nACTIVE goals (%s):\n%s\nSMT goals (%s):\n%s"
          uu____312 msg uu____313 uu____314 uu____318 uu____319
let goal_to_json: FStar_Tactics_Types.goal -> FStar_Util.json =
  fun g  ->
    let g_binders =
      let uu____328 =
        FStar_TypeChecker_Env.all_binders g.FStar_Tactics_Types.context in
      FStar_All.pipe_right uu____328 FStar_Syntax_Print.binders_to_json in
    let uu____329 =
      let uu____336 =
        let uu____343 =
          let uu____348 =
            let uu____349 =
              let uu____356 =
                let uu____361 =
                  let uu____362 =
                    FStar_TypeChecker_Normalize.term_to_string
                      g.FStar_Tactics_Types.context
                      g.FStar_Tactics_Types.witness in
                  FStar_Util.JsonStr uu____362 in
                ("witness", uu____361) in
              let uu____363 =
                let uu____370 =
                  let uu____375 =
                    let uu____376 =
                      FStar_TypeChecker_Normalize.term_to_string
                        g.FStar_Tactics_Types.context
                        g.FStar_Tactics_Types.goal_ty in
                    FStar_Util.JsonStr uu____376 in
                  ("type", uu____375) in
                [uu____370] in
              uu____356 :: uu____363 in
            FStar_Util.JsonAssoc uu____349 in
          ("goal", uu____348) in
        [uu____343] in
      ("hyps", g_binders) :: uu____336 in
    FStar_Util.JsonAssoc uu____329
let ps_to_json:
  (Prims.string,FStar_Tactics_Types.proofstate)
    FStar_Pervasives_Native.tuple2 -> FStar_Util.json
  =
  fun uu____408  ->
    match uu____408 with
    | (msg,ps) ->
        let uu____415 =
          let uu____422 =
            let uu____429 =
              let uu____434 =
                let uu____435 =
                  FStar_List.map goal_to_json ps.FStar_Tactics_Types.goals in
                FStar_Util.JsonList uu____435 in
              ("goals", uu____434) in
            let uu____438 =
              let uu____445 =
                let uu____450 =
                  let uu____451 =
                    FStar_List.map goal_to_json
                      ps.FStar_Tactics_Types.smt_goals in
                  FStar_Util.JsonList uu____451 in
                ("smt-goals", uu____450) in
              [uu____445] in
            uu____429 :: uu____438 in
          ("label", (FStar_Util.JsonStr msg)) :: uu____422 in
        FStar_Util.JsonAssoc uu____415
let dump_proofstate:
  FStar_Tactics_Types.proofstate -> Prims.string -> Prims.unit =
  fun ps  ->
    fun msg  ->
      FStar_Options.with_saved_options
        (fun uu____480  ->
           FStar_Options.set_option "print_effect_args"
             (FStar_Options.Bool true);
           FStar_Util.print_generic "proof-state" ps_to_string ps_to_json
             (msg, ps))
let print_proof_state1: Prims.string -> Prims.unit tac =
  fun msg  ->
    mk_tac (fun p  -> dump_cur p msg; FStar_Tactics_Result.Success ((), p))
let print_proof_state: Prims.string -> Prims.unit tac =
  fun msg  ->
    mk_tac
      (fun p  -> dump_proofstate p msg; FStar_Tactics_Result.Success ((), p))
let get: FStar_Tactics_Types.proofstate tac =
  mk_tac (fun p  -> FStar_Tactics_Result.Success (p, p))
let tac_verb_dbg: Prims.bool FStar_Pervasives_Native.option FStar_ST.ref =
  FStar_Util.mk_ref FStar_Pervasives_Native.None
let rec log:
  FStar_Tactics_Types.proofstate -> (Prims.unit -> Prims.unit) -> Prims.unit
  =
  fun ps  ->
    fun f  ->
      let uu____540 = FStar_ST.op_Bang tac_verb_dbg in
      match uu____540 with
      | FStar_Pervasives_Native.None  ->
          ((let uu____594 =
              let uu____597 =
                FStar_TypeChecker_Env.debug
                  ps.FStar_Tactics_Types.main_context
                  (FStar_Options.Other "TacVerbose") in
              FStar_Pervasives_Native.Some uu____597 in
            FStar_ST.op_Colon_Equals tac_verb_dbg uu____594);
           log ps f)
      | FStar_Pervasives_Native.Some (true ) -> f ()
      | FStar_Pervasives_Native.Some (false ) -> ()
let mlog: 'a . (Prims.unit -> Prims.unit) -> (Prims.unit -> 'a tac) -> 'a tac
  = fun f  -> fun cont  -> bind get (fun ps  -> log ps f; cont ())
let fail: 'Auu____687 . Prims.string -> 'Auu____687 tac =
  fun msg  ->
    mk_tac
      (fun ps  ->
         (let uu____698 =
            FStar_TypeChecker_Env.debug ps.FStar_Tactics_Types.main_context
              (FStar_Options.Other "TacFail") in
          if uu____698
          then dump_proofstate ps (Prims.strcat "TACTING FAILING: " msg)
          else ());
         FStar_Tactics_Result.Failed (msg, ps))
let fail1: 'Auu____706 . Prims.string -> Prims.string -> 'Auu____706 tac =
  fun msg  ->
    fun x  -> let uu____717 = FStar_Util.format1 msg x in fail uu____717
let fail2:
  'Auu____726 .
    Prims.string -> Prims.string -> Prims.string -> 'Auu____726 tac
  =
  fun msg  ->
    fun x  ->
      fun y  -> let uu____741 = FStar_Util.format2 msg x y in fail uu____741
let fail3:
  'Auu____752 .
    Prims.string ->
      Prims.string -> Prims.string -> Prims.string -> 'Auu____752 tac
  =
  fun msg  ->
    fun x  ->
      fun y  ->
        fun z  ->
          let uu____771 = FStar_Util.format3 msg x y z in fail uu____771
let trytac: 'a . 'a tac -> 'a FStar_Pervasives_Native.option tac =
  fun t  ->
    mk_tac
      (fun ps  ->
         let tx = FStar_Syntax_Unionfind.new_transaction () in
         let uu____799 = run t ps in
         match uu____799 with
         | FStar_Tactics_Result.Success (a,q) ->
             (FStar_Syntax_Unionfind.commit tx;
              FStar_Tactics_Result.Success
                ((FStar_Pervasives_Native.Some a), q))
         | FStar_Tactics_Result.Failed (uu____813,uu____814) ->
             (FStar_Syntax_Unionfind.rollback tx;
              FStar_Tactics_Result.Success (FStar_Pervasives_Native.None, ps)))
let set: FStar_Tactics_Types.proofstate -> Prims.unit tac =
  fun p  -> mk_tac (fun uu____829  -> FStar_Tactics_Result.Success ((), p))
let do_unify:
  env -> FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.bool =
  fun env  ->
    fun t1  ->
      fun t2  ->
        try FStar_TypeChecker_Rel.teq_nosmt env t1 t2
        with | uu____847 -> false
let trysolve:
  FStar_Tactics_Types.goal -> FStar_Syntax_Syntax.term -> Prims.bool =
  fun goal  ->
    fun solution  ->
      do_unify goal.FStar_Tactics_Types.context solution
        goal.FStar_Tactics_Types.witness
let dismiss: Prims.unit tac =
  bind get
    (fun p  ->
       let uu____861 =
         let uu___117_862 = p in
         let uu____863 = FStar_List.tl p.FStar_Tactics_Types.goals in
         {
           FStar_Tactics_Types.main_context =
             (uu___117_862.FStar_Tactics_Types.main_context);
           FStar_Tactics_Types.main_goal =
             (uu___117_862.FStar_Tactics_Types.main_goal);
           FStar_Tactics_Types.all_implicits =
             (uu___117_862.FStar_Tactics_Types.all_implicits);
           FStar_Tactics_Types.goals = uu____863;
           FStar_Tactics_Types.smt_goals =
             (uu___117_862.FStar_Tactics_Types.smt_goals);
           FStar_Tactics_Types.depth =
             (uu___117_862.FStar_Tactics_Types.depth);
           FStar_Tactics_Types.__dump =
             (uu___117_862.FStar_Tactics_Types.__dump)
         } in
       set uu____861)
let solve:
  FStar_Tactics_Types.goal -> FStar_Syntax_Syntax.term -> Prims.unit tac =
  fun goal  ->
    fun solution  ->
      let uu____878 = trysolve goal solution in
      if uu____878
      then dismiss
      else
        (let uu____882 =
           let uu____883 =
             FStar_TypeChecker_Normalize.term_to_string
               goal.FStar_Tactics_Types.context solution in
           let uu____884 =
             FStar_TypeChecker_Normalize.term_to_string
               goal.FStar_Tactics_Types.context
               goal.FStar_Tactics_Types.witness in
           let uu____885 =
             FStar_TypeChecker_Normalize.term_to_string
               goal.FStar_Tactics_Types.context
               goal.FStar_Tactics_Types.goal_ty in
           FStar_Util.format3 "%s does not solve %s : %s" uu____883 uu____884
             uu____885 in
         fail uu____882)
let dismiss_all: Prims.unit tac =
  bind get
    (fun p  ->
       set
         (let uu___118_892 = p in
          {
            FStar_Tactics_Types.main_context =
              (uu___118_892.FStar_Tactics_Types.main_context);
            FStar_Tactics_Types.main_goal =
              (uu___118_892.FStar_Tactics_Types.main_goal);
            FStar_Tactics_Types.all_implicits =
              (uu___118_892.FStar_Tactics_Types.all_implicits);
            FStar_Tactics_Types.goals = [];
            FStar_Tactics_Types.smt_goals =
              (uu___118_892.FStar_Tactics_Types.smt_goals);
            FStar_Tactics_Types.depth =
              (uu___118_892.FStar_Tactics_Types.depth);
            FStar_Tactics_Types.__dump =
              (uu___118_892.FStar_Tactics_Types.__dump)
          }))
let add_goals: FStar_Tactics_Types.goal Prims.list -> Prims.unit tac =
  fun gs  ->
    bind get
      (fun p  ->
         set
           (let uu___119_909 = p in
            {
              FStar_Tactics_Types.main_context =
                (uu___119_909.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.main_goal =
                (uu___119_909.FStar_Tactics_Types.main_goal);
              FStar_Tactics_Types.all_implicits =
                (uu___119_909.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (FStar_List.append gs p.FStar_Tactics_Types.goals);
              FStar_Tactics_Types.smt_goals =
                (uu___119_909.FStar_Tactics_Types.smt_goals);
              FStar_Tactics_Types.depth =
                (uu___119_909.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___119_909.FStar_Tactics_Types.__dump)
            }))
let add_smt_goals: FStar_Tactics_Types.goal Prims.list -> Prims.unit tac =
  fun gs  ->
    bind get
      (fun p  ->
         set
           (let uu___120_926 = p in
            {
              FStar_Tactics_Types.main_context =
                (uu___120_926.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.main_goal =
                (uu___120_926.FStar_Tactics_Types.main_goal);
              FStar_Tactics_Types.all_implicits =
                (uu___120_926.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (uu___120_926.FStar_Tactics_Types.goals);
              FStar_Tactics_Types.smt_goals =
                (FStar_List.append gs p.FStar_Tactics_Types.smt_goals);
              FStar_Tactics_Types.depth =
                (uu___120_926.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___120_926.FStar_Tactics_Types.__dump)
            }))
let push_goals: FStar_Tactics_Types.goal Prims.list -> Prims.unit tac =
  fun gs  ->
    bind get
      (fun p  ->
         set
           (let uu___121_943 = p in
            {
              FStar_Tactics_Types.main_context =
                (uu___121_943.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.main_goal =
                (uu___121_943.FStar_Tactics_Types.main_goal);
              FStar_Tactics_Types.all_implicits =
                (uu___121_943.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (FStar_List.append p.FStar_Tactics_Types.goals gs);
              FStar_Tactics_Types.smt_goals =
                (uu___121_943.FStar_Tactics_Types.smt_goals);
              FStar_Tactics_Types.depth =
                (uu___121_943.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___121_943.FStar_Tactics_Types.__dump)
            }))
let push_smt_goals: FStar_Tactics_Types.goal Prims.list -> Prims.unit tac =
  fun gs  ->
    bind get
      (fun p  ->
         set
           (let uu___122_960 = p in
            {
              FStar_Tactics_Types.main_context =
                (uu___122_960.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.main_goal =
                (uu___122_960.FStar_Tactics_Types.main_goal);
              FStar_Tactics_Types.all_implicits =
                (uu___122_960.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (uu___122_960.FStar_Tactics_Types.goals);
              FStar_Tactics_Types.smt_goals =
                (FStar_List.append p.FStar_Tactics_Types.smt_goals gs);
              FStar_Tactics_Types.depth =
                (uu___122_960.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___122_960.FStar_Tactics_Types.__dump)
            }))
let replace_cur: FStar_Tactics_Types.goal -> Prims.unit tac =
  fun g  -> bind dismiss (fun uu____970  -> add_goals [g])
let add_implicits: implicits -> Prims.unit tac =
  fun i  ->
    bind get
      (fun p  ->
         set
           (let uu___123_983 = p in
            {
              FStar_Tactics_Types.main_context =
                (uu___123_983.FStar_Tactics_Types.main_context);
              FStar_Tactics_Types.main_goal =
                (uu___123_983.FStar_Tactics_Types.main_goal);
              FStar_Tactics_Types.all_implicits =
                (FStar_List.append i p.FStar_Tactics_Types.all_implicits);
              FStar_Tactics_Types.goals =
                (uu___123_983.FStar_Tactics_Types.goals);
              FStar_Tactics_Types.smt_goals =
                (uu___123_983.FStar_Tactics_Types.smt_goals);
              FStar_Tactics_Types.depth =
                (uu___123_983.FStar_Tactics_Types.depth);
              FStar_Tactics_Types.__dump =
                (uu___123_983.FStar_Tactics_Types.__dump)
            }))
let new_uvar:
  Prims.string ->
    env -> FStar_Syntax_Syntax.typ -> FStar_Syntax_Syntax.term tac
  =
  fun reason  ->
    fun env  ->
      fun typ  ->
        let uu____1012 =
          FStar_TypeChecker_Util.new_implicit_var reason
            typ.FStar_Syntax_Syntax.pos env typ in
        match uu____1012 with
        | (u,uu____1028,g_u) ->
            let uu____1042 =
              add_implicits g_u.FStar_TypeChecker_Env.implicits in
            bind uu____1042 (fun uu____1046  -> ret u)
let is_true: FStar_Syntax_Syntax.term -> Prims.bool =
  fun t  ->
    let uu____1051 = FStar_Syntax_Util.un_squash t in
    match uu____1051 with
    | FStar_Pervasives_Native.Some t' ->
        let uu____1061 =
          let uu____1062 = FStar_Syntax_Subst.compress t' in
          uu____1062.FStar_Syntax_Syntax.n in
        (match uu____1061 with
         | FStar_Syntax_Syntax.Tm_fvar fv ->
             FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.true_lid
         | uu____1066 -> false)
    | uu____1067 -> false
let is_false: FStar_Syntax_Syntax.term -> Prims.bool =
  fun t  ->
    let uu____1076 = FStar_Syntax_Util.un_squash t in
    match uu____1076 with
    | FStar_Pervasives_Native.Some t' ->
        let uu____1086 =
          let uu____1087 = FStar_Syntax_Subst.compress t' in
          uu____1087.FStar_Syntax_Syntax.n in
        (match uu____1086 with
         | FStar_Syntax_Syntax.Tm_fvar fv ->
             FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.false_lid
         | uu____1091 -> false)
    | uu____1092 -> false
let cur_goal: FStar_Tactics_Types.goal tac =
  bind get
    (fun p  ->
       match p.FStar_Tactics_Types.goals with
       | [] -> fail "No more goals (1)"
       | hd1::tl1 -> ret hd1)
let mk_irrelevant_goal:
  Prims.string ->
    env ->
      FStar_Syntax_Syntax.typ ->
        FStar_Options.optionstate -> FStar_Tactics_Types.goal tac
  =
  fun reason  ->
    fun env  ->
      fun phi  ->
        fun opts  ->
          let typ = FStar_Syntax_Util.mk_squash phi in
          let uu____1130 = new_uvar reason env typ in
          bind uu____1130
            (fun u  ->
               let goal =
                 {
                   FStar_Tactics_Types.context = env;
                   FStar_Tactics_Types.witness = u;
                   FStar_Tactics_Types.goal_ty = typ;
                   FStar_Tactics_Types.opts = opts;
                   FStar_Tactics_Types.is_guard = false
                 } in
               ret goal)
let tc: FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.typ tac =
  fun t  ->
    bind cur_goal
      (fun goal  ->
         let uu____1148 =
           try
             let uu____1176 =
               (goal.FStar_Tactics_Types.context).FStar_TypeChecker_Env.type_of
                 goal.FStar_Tactics_Types.context t in
             ret uu____1176
           with | e -> fail "tc: not typeable" in
         bind uu____1148
           (fun uu____1218  ->
              match uu____1218 with
              | (t1,typ,guard) ->
                  let uu____1230 =
                    let uu____1231 =
                      let uu____1232 =
                        FStar_TypeChecker_Rel.discharge_guard
                          goal.FStar_Tactics_Types.context guard in
                      FStar_All.pipe_left FStar_TypeChecker_Rel.is_trivial
                        uu____1232 in
                    Prims.op_Negation uu____1231 in
                  if uu____1230
                  then fail "tc: got non-trivial guard"
                  else ret typ))
let add_irrelevant_goal:
  Prims.string ->
    env ->
      FStar_Syntax_Syntax.typ -> FStar_Options.optionstate -> Prims.unit tac
  =
  fun reason  ->
    fun env  ->
      fun phi  ->
        fun opts  ->
          let uu____1256 = mk_irrelevant_goal reason env phi opts in
          bind uu____1256 (fun goal  -> add_goals [goal])
let istrivial: env -> FStar_Syntax_Syntax.term -> Prims.bool =
  fun e  ->
    fun t  ->
      let steps =
        [FStar_TypeChecker_Normalize.Reify;
        FStar_TypeChecker_Normalize.UnfoldUntil
          FStar_Syntax_Syntax.Delta_constant;
        FStar_TypeChecker_Normalize.Primops;
        FStar_TypeChecker_Normalize.Simplify;
        FStar_TypeChecker_Normalize.UnfoldTac;
        FStar_TypeChecker_Normalize.Unmeta] in
      let t1 = normalize steps e t in is_true t1
let trivial: Prims.unit tac =
  bind cur_goal
    (fun goal  ->
       let uu____1278 =
         istrivial goal.FStar_Tactics_Types.context
           goal.FStar_Tactics_Types.goal_ty in
       if uu____1278
       then solve goal FStar_Syntax_Util.exp_unit
       else
         (let uu____1282 =
            FStar_TypeChecker_Normalize.term_to_string
              goal.FStar_Tactics_Types.context
              goal.FStar_Tactics_Types.goal_ty in
          fail1 "Not a trivial goal: %s" uu____1282))
let add_goal_from_guard:
  Prims.string ->
    env ->
      FStar_TypeChecker_Env.guard_t ->
        FStar_Options.optionstate -> Prims.unit tac
  =
  fun reason  ->
    fun e  ->
      fun g  ->
        fun opts  ->
          let uu____1303 =
            let uu____1304 = FStar_TypeChecker_Rel.simplify_guard e g in
            uu____1304.FStar_TypeChecker_Env.guard_f in
          match uu____1303 with
          | FStar_TypeChecker_Common.Trivial  -> ret ()
          | FStar_TypeChecker_Common.NonTrivial f ->
              let uu____1308 = istrivial e f in
              if uu____1308
              then ret ()
              else
                (let uu____1312 = mk_irrelevant_goal reason e f opts in
                 bind uu____1312
                   (fun goal  ->
                      let goal1 =
                        let uu___126_1319 = goal in
                        {
                          FStar_Tactics_Types.context =
                            (uu___126_1319.FStar_Tactics_Types.context);
                          FStar_Tactics_Types.witness =
                            (uu___126_1319.FStar_Tactics_Types.witness);
                          FStar_Tactics_Types.goal_ty =
                            (uu___126_1319.FStar_Tactics_Types.goal_ty);
                          FStar_Tactics_Types.opts =
                            (uu___126_1319.FStar_Tactics_Types.opts);
                          FStar_Tactics_Types.is_guard = true
                        } in
                      push_goals [goal1]))
let smt: Prims.unit tac =
  bind cur_goal
    (fun g  ->
       let uu____1325 = is_irrelevant g in
       if uu____1325
       then bind dismiss (fun uu____1329  -> add_smt_goals [g])
       else
         (let uu____1331 =
            FStar_TypeChecker_Normalize.term_to_string
              g.FStar_Tactics_Types.context g.FStar_Tactics_Types.goal_ty in
          fail1 "goal is not irrelevant: cannot dispatch to smt (%s)"
            uu____1331))
let divide:
  'a 'b .
    Prims.int ->
      'a tac -> 'b tac -> ('a,'b) FStar_Pervasives_Native.tuple2 tac
  =
  fun n1  ->
    fun l  ->
      fun r  ->
        bind get
          (fun p  ->
             let uu____1377 =
               try
                 let uu____1411 =
                   FStar_List.splitAt n1 p.FStar_Tactics_Types.goals in
                 ret uu____1411
               with | uu____1441 -> fail "divide: not enough goals" in
             bind uu____1377
               (fun uu____1468  ->
                  match uu____1468 with
                  | (lgs,rgs) ->
                      let lp =
                        let uu___127_1494 = p in
                        {
                          FStar_Tactics_Types.main_context =
                            (uu___127_1494.FStar_Tactics_Types.main_context);
                          FStar_Tactics_Types.main_goal =
                            (uu___127_1494.FStar_Tactics_Types.main_goal);
                          FStar_Tactics_Types.all_implicits =
                            (uu___127_1494.FStar_Tactics_Types.all_implicits);
                          FStar_Tactics_Types.goals = lgs;
                          FStar_Tactics_Types.smt_goals = [];
                          FStar_Tactics_Types.depth =
                            (uu___127_1494.FStar_Tactics_Types.depth);
                          FStar_Tactics_Types.__dump =
                            (uu___127_1494.FStar_Tactics_Types.__dump)
                        } in
                      let rp =
                        let uu___128_1496 = p in
                        {
                          FStar_Tactics_Types.main_context =
                            (uu___128_1496.FStar_Tactics_Types.main_context);
                          FStar_Tactics_Types.main_goal =
                            (uu___128_1496.FStar_Tactics_Types.main_goal);
                          FStar_Tactics_Types.all_implicits =
                            (uu___128_1496.FStar_Tactics_Types.all_implicits);
                          FStar_Tactics_Types.goals = rgs;
                          FStar_Tactics_Types.smt_goals = [];
                          FStar_Tactics_Types.depth =
                            (uu___128_1496.FStar_Tactics_Types.depth);
                          FStar_Tactics_Types.__dump =
                            (uu___128_1496.FStar_Tactics_Types.__dump)
                        } in
                      let uu____1497 = set lp in
                      bind uu____1497
                        (fun uu____1505  ->
                           bind l
                             (fun a  ->
                                bind get
                                  (fun lp'  ->
                                     let uu____1519 = set rp in
                                     bind uu____1519
                                       (fun uu____1527  ->
                                          bind r
                                            (fun b  ->
                                               bind get
                                                 (fun rp'  ->
                                                    let p' =
                                                      let uu___129_1543 = p in
                                                      {
                                                        FStar_Tactics_Types.main_context
                                                          =
                                                          (uu___129_1543.FStar_Tactics_Types.main_context);
                                                        FStar_Tactics_Types.main_goal
                                                          =
                                                          (uu___129_1543.FStar_Tactics_Types.main_goal);
                                                        FStar_Tactics_Types.all_implicits
                                                          =
                                                          (uu___129_1543.FStar_Tactics_Types.all_implicits);
                                                        FStar_Tactics_Types.goals
                                                          =
                                                          (FStar_List.append
                                                             lp'.FStar_Tactics_Types.goals
                                                             rp'.FStar_Tactics_Types.goals);
                                                        FStar_Tactics_Types.smt_goals
                                                          =
                                                          (FStar_List.append
                                                             lp'.FStar_Tactics_Types.smt_goals
                                                             (FStar_List.append
                                                                rp'.FStar_Tactics_Types.smt_goals
                                                                p.FStar_Tactics_Types.smt_goals));
                                                        FStar_Tactics_Types.depth
                                                          =
                                                          (uu___129_1543.FStar_Tactics_Types.depth);
                                                        FStar_Tactics_Types.__dump
                                                          =
                                                          (uu___129_1543.FStar_Tactics_Types.__dump)
                                                      } in
                                                    let uu____1544 = set p' in
                                                    bind uu____1544
                                                      (fun uu____1552  ->
                                                         ret (a, b))))))))))
let focus: 'a . 'a tac -> 'a tac =
  fun f  ->
    let uu____1572 = divide (Prims.parse_int "1") f idtac in
    bind uu____1572
      (fun uu____1585  -> match uu____1585 with | (a,()) -> ret a)
let rec map: 'a . 'a tac -> 'a Prims.list tac =
  fun tau  ->
    bind get
      (fun p  ->
         match p.FStar_Tactics_Types.goals with
         | [] -> ret []
         | uu____1620::uu____1621 ->
             let uu____1624 =
               let uu____1633 = map tau in
               divide (Prims.parse_int "1") tau uu____1633 in
             bind uu____1624
               (fun uu____1651  ->
                  match uu____1651 with | (h,t) -> ret (h :: t)))
let seq: Prims.unit tac -> Prims.unit tac -> Prims.unit tac =
  fun t1  ->
    fun t2  ->
      let uu____1690 =
        bind t1
          (fun uu____1695  ->
             let uu____1696 = map t2 in
             bind uu____1696 (fun uu____1704  -> ret ())) in
      focus uu____1690
let intro: FStar_Syntax_Syntax.binder tac =
  bind cur_goal
    (fun goal  ->
       let uu____1715 =
         FStar_Syntax_Util.arrow_one goal.FStar_Tactics_Types.goal_ty in
       match uu____1715 with
       | FStar_Pervasives_Native.Some (b,c) ->
           let uu____1730 =
             let uu____1731 = FStar_Syntax_Util.is_total_comp c in
             Prims.op_Negation uu____1731 in
           if uu____1730
           then fail "Codomain is effectful"
           else
             (let env' =
                FStar_TypeChecker_Env.push_binders
                  goal.FStar_Tactics_Types.context [b] in
              let typ' = comp_to_typ c in
              let uu____1737 = new_uvar "intro" env' typ' in
              bind uu____1737
                (fun u  ->
                   let uu____1744 =
                     let uu____1745 =
                       FStar_Syntax_Util.abs [b] u
                         FStar_Pervasives_Native.None in
                     trysolve goal uu____1745 in
                   if uu____1744
                   then
                     let uu____1748 =
                       let uu____1751 =
                         let uu___132_1752 = goal in
                         let uu____1753 = bnorm env' u in
                         let uu____1754 = bnorm env' typ' in
                         {
                           FStar_Tactics_Types.context = env';
                           FStar_Tactics_Types.witness = uu____1753;
                           FStar_Tactics_Types.goal_ty = uu____1754;
                           FStar_Tactics_Types.opts =
                             (uu___132_1752.FStar_Tactics_Types.opts);
                           FStar_Tactics_Types.is_guard =
                             (uu___132_1752.FStar_Tactics_Types.is_guard)
                         } in
                       replace_cur uu____1751 in
                     bind uu____1748 (fun uu____1756  -> ret b)
                   else fail "intro: unification failed"))
       | FStar_Pervasives_Native.None  ->
           let uu____1762 =
             FStar_TypeChecker_Normalize.term_to_string
               goal.FStar_Tactics_Types.context
               goal.FStar_Tactics_Types.goal_ty in
           fail1 "intro: goal is not an arrow (%s)" uu____1762)
let intro_rec:
  (FStar_Syntax_Syntax.binder,FStar_Syntax_Syntax.binder)
    FStar_Pervasives_Native.tuple2 tac
  =
  bind cur_goal
    (fun goal  ->
       FStar_Util.print_string
         "WARNING (intro_rec): calling this is known to cause normalizer loops\n";
       FStar_Util.print_string
         "WARNING (intro_rec): proceed at your own risk...\n";
       (let uu____1783 =
          FStar_Syntax_Util.arrow_one goal.FStar_Tactics_Types.goal_ty in
        match uu____1783 with
        | FStar_Pervasives_Native.Some (b,c) ->
            let uu____1802 =
              let uu____1803 = FStar_Syntax_Util.is_total_comp c in
              Prims.op_Negation uu____1803 in
            if uu____1802
            then fail "Codomain is effectful"
            else
              (let bv =
                 FStar_Syntax_Syntax.gen_bv "__recf"
                   FStar_Pervasives_Native.None
                   goal.FStar_Tactics_Types.goal_ty in
               let bs =
                 let uu____1819 = FStar_Syntax_Syntax.mk_binder bv in
                 [uu____1819; b] in
               let env' =
                 FStar_TypeChecker_Env.push_binders
                   goal.FStar_Tactics_Types.context bs in
               let uu____1821 =
                 let uu____1824 = comp_to_typ c in
                 new_uvar "intro_rec" env' uu____1824 in
               bind uu____1821
                 (fun u  ->
                    let lb =
                      let uu____1840 =
                        FStar_Syntax_Util.abs [b] u
                          FStar_Pervasives_Native.None in
                      FStar_Syntax_Util.mk_letbinding (FStar_Util.Inl bv) []
                        goal.FStar_Tactics_Types.goal_ty
                        FStar_Parser_Const.effect_Tot_lid uu____1840 in
                    let body = FStar_Syntax_Syntax.bv_to_name bv in
                    let uu____1844 =
                      FStar_Syntax_Subst.close_let_rec [lb] body in
                    match uu____1844 with
                    | (lbs,body1) ->
                        let tm =
                          FStar_Syntax_Syntax.mk
                            (FStar_Syntax_Syntax.Tm_let ((true, lbs), body1))
                            FStar_Pervasives_Native.None
                            (goal.FStar_Tactics_Types.witness).FStar_Syntax_Syntax.pos in
                        let res = trysolve goal tm in
                        if res
                        then
                          let uu____1881 =
                            let uu____1884 =
                              let uu___133_1885 = goal in
                              let uu____1886 = bnorm env' u in
                              let uu____1887 =
                                let uu____1888 = comp_to_typ c in
                                bnorm env' uu____1888 in
                              {
                                FStar_Tactics_Types.context = env';
                                FStar_Tactics_Types.witness = uu____1886;
                                FStar_Tactics_Types.goal_ty = uu____1887;
                                FStar_Tactics_Types.opts =
                                  (uu___133_1885.FStar_Tactics_Types.opts);
                                FStar_Tactics_Types.is_guard =
                                  (uu___133_1885.FStar_Tactics_Types.is_guard)
                              } in
                            replace_cur uu____1884 in
                          bind uu____1881
                            (fun uu____1895  ->
                               let uu____1896 =
                                 let uu____1901 =
                                   FStar_Syntax_Syntax.mk_binder bv in
                                 (uu____1901, b) in
                               ret uu____1896)
                        else fail "intro_rec: unification failed"))
        | FStar_Pervasives_Native.None  ->
            let uu____1915 =
              FStar_TypeChecker_Normalize.term_to_string
                goal.FStar_Tactics_Types.context
                goal.FStar_Tactics_Types.goal_ty in
            fail1 "intro_rec: goal is not an arrow (%s)" uu____1915))
let norm: FStar_Syntax_Embeddings.norm_step Prims.list -> Prims.unit tac =
  fun s  ->
    bind cur_goal
      (fun goal  ->
         let steps =
           let uu____1940 = FStar_TypeChecker_Normalize.tr_norm_steps s in
           FStar_List.append
             [FStar_TypeChecker_Normalize.Reify;
             FStar_TypeChecker_Normalize.UnfoldTac] uu____1940 in
         let w =
           normalize steps goal.FStar_Tactics_Types.context
             goal.FStar_Tactics_Types.witness in
         let t =
           normalize steps goal.FStar_Tactics_Types.context
             goal.FStar_Tactics_Types.goal_ty in
         replace_cur
           (let uu___134_1947 = goal in
            {
              FStar_Tactics_Types.context =
                (uu___134_1947.FStar_Tactics_Types.context);
              FStar_Tactics_Types.witness = w;
              FStar_Tactics_Types.goal_ty = t;
              FStar_Tactics_Types.opts =
                (uu___134_1947.FStar_Tactics_Types.opts);
              FStar_Tactics_Types.is_guard =
                (uu___134_1947.FStar_Tactics_Types.is_guard)
            }))
let norm_term:
  FStar_Syntax_Embeddings.norm_step Prims.list ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term tac
  =
  fun s  ->
    fun t  ->
      bind get
        (fun ps  ->
           let steps =
             let uu____1971 = FStar_TypeChecker_Normalize.tr_norm_steps s in
             FStar_List.append
               [FStar_TypeChecker_Normalize.Reify;
               FStar_TypeChecker_Normalize.UnfoldTac] uu____1971 in
           let t1 = normalize steps ps.FStar_Tactics_Types.main_context t in
           ret t1)
let __exact: FStar_Syntax_Syntax.term -> Prims.unit tac =
  fun t  ->
    bind cur_goal
      (fun goal  ->
         let uu____1986 =
           try
             let uu____2014 =
               (goal.FStar_Tactics_Types.context).FStar_TypeChecker_Env.type_of
                 goal.FStar_Tactics_Types.context t in
             ret uu____2014
           with
           | e ->
               let uu____2041 = FStar_Syntax_Print.term_to_string t in
               let uu____2042 = FStar_Syntax_Print.tag_of_term t in
               fail2 "exact: term is not typeable: %s (%s)" uu____2041
                 uu____2042 in
         bind uu____1986
           (fun uu____2060  ->
              match uu____2060 with
              | (t1,typ,guard) ->
                  let uu____2072 =
                    let uu____2073 =
                      let uu____2074 =
                        FStar_TypeChecker_Rel.discharge_guard
                          goal.FStar_Tactics_Types.context guard in
                      FStar_All.pipe_left FStar_TypeChecker_Rel.is_trivial
                        uu____2074 in
                    Prims.op_Negation uu____2073 in
                  if uu____2072
                  then fail "exact: got non-trivial guard"
                  else
                    (let uu____2078 =
                       do_unify goal.FStar_Tactics_Types.context typ
                         goal.FStar_Tactics_Types.goal_ty in
                     if uu____2078
                     then solve goal t1
                     else
                       (let uu____2082 =
                          FStar_TypeChecker_Normalize.term_to_string
                            goal.FStar_Tactics_Types.context t1 in
                        let uu____2083 =
                          let uu____2084 =
                            bnorm goal.FStar_Tactics_Types.context typ in
                          FStar_TypeChecker_Normalize.term_to_string
                            goal.FStar_Tactics_Types.context uu____2084 in
                        let uu____2085 =
                          FStar_TypeChecker_Normalize.term_to_string
                            goal.FStar_Tactics_Types.context
                            goal.FStar_Tactics_Types.goal_ty in
                        fail3 "%s : %s does not exactly solve the goal %s"
                          uu____2082 uu____2083 uu____2085))))
let exact: FStar_Syntax_Syntax.term -> Prims.unit tac =
  fun tm  ->
    mlog
      (fun uu____2096  ->
         let uu____2097 = FStar_Syntax_Print.term_to_string tm in
         FStar_Util.print1 "exact: tm = %s\n" uu____2097)
      (fun uu____2100  -> let uu____2101 = __exact tm in focus uu____2101)
let uvar_free_in_goal:
  FStar_Syntax_Syntax.uvar -> FStar_Tactics_Types.goal -> Prims.bool =
  fun u  ->
    fun g  ->
      if g.FStar_Tactics_Types.is_guard
      then false
      else
        (let free_uvars =
           let uu____2116 =
             let uu____2123 =
               FStar_Syntax_Free.uvars g.FStar_Tactics_Types.goal_ty in
             FStar_Util.set_elements uu____2123 in
           FStar_List.map FStar_Pervasives_Native.fst uu____2116 in
         FStar_List.existsML (FStar_Syntax_Unionfind.equiv u) free_uvars)
let uvar_free:
  FStar_Syntax_Syntax.uvar -> FStar_Tactics_Types.proofstate -> Prims.bool =
  fun u  ->
    fun ps  ->
      FStar_List.existsML (uvar_free_in_goal u) ps.FStar_Tactics_Types.goals
exception NoUnif
let uu___is_NoUnif: Prims.exn -> Prims.bool =
  fun projectee  ->
    match projectee with | NoUnif  -> true | uu____2150 -> false
let rec __apply:
  Prims.bool ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.typ -> Prims.unit tac
  =
  fun uopt  ->
    fun tm  ->
      fun typ  ->
        bind cur_goal
          (fun goal  ->
             let uu____2170 =
               let uu____2175 = __exact tm in trytac uu____2175 in
             bind uu____2170
               (fun r  ->
                  match r with
                  | FStar_Pervasives_Native.Some r1 -> ret ()
                  | FStar_Pervasives_Native.None  ->
                      let uu____2188 = FStar_Syntax_Util.arrow_one typ in
                      (match uu____2188 with
                       | FStar_Pervasives_Native.None  ->
                           FStar_Exn.raise NoUnif
                       | FStar_Pervasives_Native.Some ((bv,aq),c) ->
                           mlog
                             (fun uu____2220  ->
                                let uu____2221 =
                                  FStar_Syntax_Print.binder_to_string
                                    (bv, aq) in
                                FStar_Util.print1
                                  "__apply: pushing binder %s\n" uu____2221)
                             (fun uu____2224  ->
                                let uu____2225 =
                                  let uu____2226 =
                                    FStar_Syntax_Util.is_total_comp c in
                                  Prims.op_Negation uu____2226 in
                                if uu____2225
                                then fail "apply: not total codomain"
                                else
                                  (let uu____2230 =
                                     new_uvar "apply"
                                       goal.FStar_Tactics_Types.context
                                       bv.FStar_Syntax_Syntax.sort in
                                   bind uu____2230
                                     (fun u  ->
                                        let tm' =
                                          FStar_Syntax_Syntax.mk_Tm_app tm
                                            [(u, aq)]
                                            FStar_Pervasives_Native.None
                                            (goal.FStar_Tactics_Types.context).FStar_TypeChecker_Env.range in
                                        let typ' =
                                          let uu____2250 = comp_to_typ c in
                                          FStar_All.pipe_left
                                            (FStar_Syntax_Subst.subst
                                               [FStar_Syntax_Syntax.NT
                                                  (bv, u)]) uu____2250 in
                                        let uu____2251 =
                                          __apply uopt tm' typ' in
                                        bind uu____2251
                                          (fun uu____2259  ->
                                             let u1 =
                                               bnorm
                                                 goal.FStar_Tactics_Types.context
                                                 u in
                                             let uu____2261 =
                                               let uu____2262 =
                                                 let uu____2265 =
                                                   let uu____2266 =
                                                     FStar_Syntax_Util.head_and_args
                                                       u1 in
                                                   FStar_Pervasives_Native.fst
                                                     uu____2266 in
                                                 FStar_Syntax_Subst.compress
                                                   uu____2265 in
                                               uu____2262.FStar_Syntax_Syntax.n in
                                             match uu____2261 with
                                             | FStar_Syntax_Syntax.Tm_uvar
                                                 (uvar,uu____2294) ->
                                                 bind get
                                                   (fun ps  ->
                                                      let uu____2322 =
                                                        uopt &&
                                                          (uvar_free uvar ps) in
                                                      if uu____2322
                                                      then ret ()
                                                      else
                                                        (let uu____2326 =
                                                           let uu____2329 =
                                                             let uu___137_2330
                                                               = goal in
                                                             let uu____2331 =
                                                               bnorm
                                                                 goal.FStar_Tactics_Types.context
                                                                 u1 in
                                                             let uu____2332 =
                                                               bnorm
                                                                 goal.FStar_Tactics_Types.context
                                                                 bv.FStar_Syntax_Syntax.sort in
                                                             {
                                                               FStar_Tactics_Types.context
                                                                 =
                                                                 (uu___137_2330.FStar_Tactics_Types.context);
                                                               FStar_Tactics_Types.witness
                                                                 = uu____2331;
                                                               FStar_Tactics_Types.goal_ty
                                                                 = uu____2332;
                                                               FStar_Tactics_Types.opts
                                                                 =
                                                                 (uu___137_2330.FStar_Tactics_Types.opts);
                                                               FStar_Tactics_Types.is_guard
                                                                 = false
                                                             } in
                                                           [uu____2329] in
                                                         add_goals uu____2326))
                                             | t -> ret ())))))))
let try_unif: 'a . 'a tac -> 'a tac -> 'a tac =
  fun t  ->
    fun t'  -> mk_tac (fun ps  -> try run t ps with | NoUnif  -> run t' ps)
let apply: Prims.bool -> FStar_Syntax_Syntax.term -> Prims.unit tac =
  fun uopt  ->
    fun tm  ->
      mlog
        (fun uu____2385  ->
           let uu____2386 = FStar_Syntax_Print.term_to_string tm in
           FStar_Util.print1 "apply: tm = %s\n" uu____2386)
        (fun uu____2388  ->
           bind cur_goal
             (fun goal  ->
                let uu____2397 =
                  (goal.FStar_Tactics_Types.context).FStar_TypeChecker_Env.type_of
                    goal.FStar_Tactics_Types.context tm in
                match uu____2397 with
                | (tm1,typ,guard) ->
                    let uu____2409 =
                      let uu____2412 =
                        let uu____2415 = __apply uopt tm1 typ in
                        bind uu____2415
                          (fun uu____2419  ->
                             add_goal_from_guard "apply guard"
                               goal.FStar_Tactics_Types.context guard
                               goal.FStar_Tactics_Types.opts) in
                      focus uu____2412 in
                    let uu____2420 =
                      let uu____2423 =
                        FStar_TypeChecker_Normalize.term_to_string
                          goal.FStar_Tactics_Types.context tm1 in
                      let uu____2424 =
                        FStar_TypeChecker_Normalize.term_to_string
                          goal.FStar_Tactics_Types.context typ in
                      let uu____2425 =
                        FStar_TypeChecker_Normalize.term_to_string
                          goal.FStar_Tactics_Types.context
                          goal.FStar_Tactics_Types.goal_ty in
                      fail3
                        "apply: Cannot instantiate %s (of type %s) to match goal (%s)"
                        uu____2423 uu____2424 uu____2425 in
                    try_unif uu____2409 uu____2420))
let apply_lemma: FStar_Syntax_Syntax.term -> Prims.unit tac =
  fun tm  ->
    let uu____2434 =
      mlog
        (fun uu____2439  ->
           let uu____2440 = FStar_Syntax_Print.term_to_string tm in
           FStar_Util.print1 "apply_lemma: tm = %s\n" uu____2440)
        (fun uu____2443  ->
           let is_unit_t t =
             let uu____2448 =
               let uu____2449 = FStar_Syntax_Subst.compress t in
               uu____2449.FStar_Syntax_Syntax.n in
             match uu____2448 with
             | FStar_Syntax_Syntax.Tm_fvar fv when
                 FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.unit_lid
                 -> true
             | uu____2453 -> false in
           bind cur_goal
             (fun goal  ->
                let uu____2463 =
                  (goal.FStar_Tactics_Types.context).FStar_TypeChecker_Env.type_of
                    goal.FStar_Tactics_Types.context tm in
                match uu____2463 with
                | (tm1,t,guard) ->
                    let uu____2475 = FStar_Syntax_Util.arrow_formals_comp t in
                    (match uu____2475 with
                     | (bs,comp) ->
                         if
                           Prims.op_Negation
                             (FStar_Syntax_Util.is_lemma_comp comp)
                         then fail "apply_lemma: not a lemma"
                         else
                           (let uu____2505 =
                              FStar_List.fold_left
                                (fun uu____2551  ->
                                   fun uu____2552  ->
                                     match (uu____2551, uu____2552) with
                                     | ((uvs,guard1,subst1),(b,aq)) ->
                                         let b_t =
                                           FStar_Syntax_Subst.subst subst1
                                             b.FStar_Syntax_Syntax.sort in
                                         let uu____2655 = is_unit_t b_t in
                                         if uu____2655
                                         then
                                           (((FStar_Syntax_Util.exp_unit, aq)
                                             :: uvs), guard1,
                                             ((FStar_Syntax_Syntax.NT
                                                 (b,
                                                   FStar_Syntax_Util.exp_unit))
                                             :: subst1))
                                         else
                                           (let uu____2693 =
                                              FStar_TypeChecker_Util.new_implicit_var
                                                "apply_lemma"
                                                (goal.FStar_Tactics_Types.goal_ty).FStar_Syntax_Syntax.pos
                                                goal.FStar_Tactics_Types.context
                                                b_t in
                                            match uu____2693 with
                                            | (u,uu____2723,g_u) ->
                                                let uu____2737 =
                                                  FStar_TypeChecker_Rel.conj_guard
                                                    guard1 g_u in
                                                (((u, aq) :: uvs),
                                                  uu____2737,
                                                  ((FStar_Syntax_Syntax.NT
                                                      (b, u)) :: subst1))))
                                ([], guard, []) bs in
                            match uu____2505 with
                            | (uvs,implicits,subst1) ->
                                let uvs1 = FStar_List.rev uvs in
                                let comp1 =
                                  FStar_Syntax_Subst.subst_comp subst1 comp in
                                let uu____2807 =
                                  let uu____2816 =
                                    let uu____2825 =
                                      FStar_Syntax_Util.comp_to_comp_typ
                                        comp1 in
                                    uu____2825.FStar_Syntax_Syntax.effect_args in
                                  match uu____2816 with
                                  | pre::post::uu____2836 ->
                                      ((FStar_Pervasives_Native.fst pre),
                                        (FStar_Pervasives_Native.fst post))
                                  | uu____2877 ->
                                      failwith
                                        "apply_lemma: impossible: not a lemma" in
                                (match uu____2807 with
                                 | (pre,post) ->
                                     let post1 =
                                       let uu____2909 =
                                         let uu____2918 =
                                           FStar_Syntax_Syntax.as_arg
                                             FStar_Syntax_Util.exp_unit in
                                         [uu____2918] in
                                       FStar_Syntax_Util.mk_app post
                                         uu____2909 in
                                     let uu____2919 =
                                       let uu____2920 =
                                         let uu____2921 =
                                           FStar_Syntax_Util.mk_squash post1 in
                                         do_unify
                                           goal.FStar_Tactics_Types.context
                                           uu____2921
                                           goal.FStar_Tactics_Types.goal_ty in
                                       Prims.op_Negation uu____2920 in
                                     if uu____2919
                                     then
                                       let uu____2924 =
                                         FStar_TypeChecker_Normalize.term_to_string
                                           goal.FStar_Tactics_Types.context
                                           tm1 in
                                       let uu____2925 =
                                         let uu____2926 =
                                           FStar_Syntax_Util.mk_squash post1 in
                                         FStar_TypeChecker_Normalize.term_to_string
                                           goal.FStar_Tactics_Types.context
                                           uu____2926 in
                                       let uu____2927 =
                                         FStar_TypeChecker_Normalize.term_to_string
                                           goal.FStar_Tactics_Types.context
                                           goal.FStar_Tactics_Types.goal_ty in
                                       fail3
                                         "apply_lemma: Cannot instantiate lemma %s (with postcondition: %s) to match goal (%s)"
                                         uu____2924 uu____2925 uu____2927
                                     else
                                       (let solution =
                                          let uu____2930 =
                                            FStar_Syntax_Syntax.mk_Tm_app tm1
                                              uvs1
                                              FStar_Pervasives_Native.None
                                              (goal.FStar_Tactics_Types.context).FStar_TypeChecker_Env.range in
                                          FStar_TypeChecker_Normalize.normalize
                                            [FStar_TypeChecker_Normalize.Beta]
                                            goal.FStar_Tactics_Types.context
                                            uu____2930 in
                                        let uu____2931 =
                                          add_implicits
                                            implicits.FStar_TypeChecker_Env.implicits in
                                        bind uu____2931
                                          (fun uu____2937  ->
                                             let implicits1 =
                                               FStar_All.pipe_right
                                                 implicits.FStar_TypeChecker_Env.implicits
                                                 (FStar_List.filter
                                                    (fun uu____3005  ->
                                                       match uu____3005 with
                                                       | (uu____3018,uu____3019,uu____3020,tm2,uu____3022,uu____3023)
                                                           ->
                                                           let uu____3024 =
                                                             FStar_Syntax_Util.head_and_args
                                                               tm2 in
                                                           (match uu____3024
                                                            with
                                                            | (hd1,uu____3040)
                                                                ->
                                                                let uu____3061
                                                                  =
                                                                  let uu____3062
                                                                    =
                                                                    FStar_Syntax_Subst.compress
                                                                    hd1 in
                                                                  uu____3062.FStar_Syntax_Syntax.n in
                                                                (match uu____3061
                                                                 with
                                                                 | FStar_Syntax_Syntax.Tm_uvar
                                                                    uu____3065
                                                                    -> true
                                                                 | uu____3082
                                                                    -> false)))) in
                                             let uu____3083 =
                                               solve goal solution in
                                             bind uu____3083
                                               (fun uu____3094  ->
                                                  let is_free_uvar uv t1 =
                                                    let free_uvars =
                                                      let uu____3105 =
                                                        let uu____3112 =
                                                          FStar_Syntax_Free.uvars
                                                            t1 in
                                                        FStar_Util.set_elements
                                                          uu____3112 in
                                                      FStar_List.map
                                                        FStar_Pervasives_Native.fst
                                                        uu____3105 in
                                                    FStar_List.existsML
                                                      (fun u  ->
                                                         FStar_Syntax_Unionfind.equiv
                                                           u uv) free_uvars in
                                                  let appears uv goals =
                                                    FStar_List.existsML
                                                      (fun g'  ->
                                                         is_free_uvar uv
                                                           g'.FStar_Tactics_Types.goal_ty)
                                                      goals in
                                                  let checkone t1 goals =
                                                    let uu____3153 =
                                                      FStar_Syntax_Util.head_and_args
                                                        t1 in
                                                    match uu____3153 with
                                                    | (hd1,uu____3169) ->
                                                        (match hd1.FStar_Syntax_Syntax.n
                                                         with
                                                         | FStar_Syntax_Syntax.Tm_uvar
                                                             (uv,uu____3191)
                                                             ->
                                                             appears uv goals
                                                         | uu____3216 ->
                                                             false) in
                                                  let sub_goals =
                                                    FStar_All.pipe_right
                                                      implicits1
                                                      (FStar_List.map
                                                         (fun uu____3258  ->
                                                            match uu____3258
                                                            with
                                                            | (_msg,_env,_uvar,term,typ,uu____3276)
                                                                ->
                                                                let uu___140_3277
                                                                  = goal in
                                                                let uu____3278
                                                                  =
                                                                  bnorm
                                                                    goal.FStar_Tactics_Types.context
                                                                    term in
                                                                let uu____3279
                                                                  =
                                                                  bnorm
                                                                    goal.FStar_Tactics_Types.context
                                                                    typ in
                                                                {
                                                                  FStar_Tactics_Types.context
                                                                    =
                                                                    (
                                                                    uu___140_3277.FStar_Tactics_Types.context);
                                                                  FStar_Tactics_Types.witness
                                                                    =
                                                                    uu____3278;
                                                                  FStar_Tactics_Types.goal_ty
                                                                    =
                                                                    uu____3279;
                                                                  FStar_Tactics_Types.opts
                                                                    =
                                                                    (
                                                                    uu___140_3277.FStar_Tactics_Types.opts);
                                                                  FStar_Tactics_Types.is_guard
                                                                    =
                                                                    (
                                                                    uu___140_3277.FStar_Tactics_Types.is_guard)
                                                                })) in
                                                  let rec filter' f xs =
                                                    match xs with
                                                    | [] -> []
                                                    | x::xs1 ->
                                                        let uu____3317 =
                                                          f x xs1 in
                                                        if uu____3317
                                                        then
                                                          let uu____3320 =
                                                            filter' f xs1 in
                                                          x :: uu____3320
                                                        else filter' f xs1 in
                                                  let sub_goals1 =
                                                    filter'
                                                      (fun g  ->
                                                         fun goals  ->
                                                           let uu____3334 =
                                                             checkone
                                                               g.FStar_Tactics_Types.witness
                                                               goals in
                                                           Prims.op_Negation
                                                             uu____3334)
                                                      sub_goals in
                                                  let uu____3335 =
                                                    add_goal_from_guard
                                                      "apply_lemma guard"
                                                      goal.FStar_Tactics_Types.context
                                                      guard
                                                      goal.FStar_Tactics_Types.opts in
                                                  bind uu____3335
                                                    (fun uu____3340  ->
                                                       let uu____3341 =
                                                         let uu____3344 =
                                                           let uu____3345 =
                                                             let uu____3346 =
                                                               FStar_Syntax_Util.mk_squash
                                                                 pre in
                                                             istrivial
                                                               goal.FStar_Tactics_Types.context
                                                               uu____3346 in
                                                           Prims.op_Negation
                                                             uu____3345 in
                                                         if uu____3344
                                                         then
                                                           add_irrelevant_goal
                                                             "apply_lemma precondition"
                                                             goal.FStar_Tactics_Types.context
                                                             pre
                                                             goal.FStar_Tactics_Types.opts
                                                         else ret () in
                                                       bind uu____3341
                                                         (fun uu____3351  ->
                                                            add_goals
                                                              sub_goals1)))))))))) in
    focus uu____2434
let destruct_eq':
  FStar_Syntax_Syntax.typ ->
    (FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.term)
      FStar_Pervasives_Native.tuple2 FStar_Pervasives_Native.option
  =
  fun typ  ->
    let uu____3368 = FStar_Syntax_Util.destruct_typ_as_formula typ in
    match uu____3368 with
    | FStar_Pervasives_Native.Some (FStar_Syntax_Util.BaseConn
        (l,uu____3378::(e1,uu____3380)::(e2,uu____3382)::[])) when
        FStar_Ident.lid_equals l FStar_Parser_Const.eq2_lid ->
        FStar_Pervasives_Native.Some (e1, e2)
    | uu____3441 -> FStar_Pervasives_Native.None
let destruct_eq:
  FStar_Syntax_Syntax.typ ->
    (FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.term)
      FStar_Pervasives_Native.tuple2 FStar_Pervasives_Native.option
  =
  fun typ  ->
    let uu____3464 = destruct_eq' typ in
    match uu____3464 with
    | FStar_Pervasives_Native.Some t -> FStar_Pervasives_Native.Some t
    | FStar_Pervasives_Native.None  ->
        let uu____3494 = FStar_Syntax_Util.un_squash typ in
        (match uu____3494 with
         | FStar_Pervasives_Native.Some typ1 -> destruct_eq' typ1
         | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None)
let split_env:
  FStar_Syntax_Syntax.bv ->
    env ->
      (env,FStar_Syntax_Syntax.bv Prims.list) FStar_Pervasives_Native.tuple2
        FStar_Pervasives_Native.option
  =
  fun bvar  ->
    fun e  ->
      let rec aux e1 =
        let uu____3552 = FStar_TypeChecker_Env.pop_bv e1 in
        match uu____3552 with
        | FStar_Pervasives_Native.None  -> FStar_Pervasives_Native.None
        | FStar_Pervasives_Native.Some (bv',e') ->
            if FStar_Syntax_Syntax.bv_eq bvar bv'
            then FStar_Pervasives_Native.Some (e', [])
            else
              (let uu____3600 = aux e' in
               FStar_Util.map_opt uu____3600
                 (fun uu____3624  ->
                    match uu____3624 with | (e'',bvs) -> (e'', (bv' :: bvs)))) in
      let uu____3645 = aux e in
      FStar_Util.map_opt uu____3645
        (fun uu____3669  ->
           match uu____3669 with | (e',bvs) -> (e', (FStar_List.rev bvs)))
let push_bvs:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.bv Prims.list -> FStar_TypeChecker_Env.env
  =
  fun e  ->
    fun bvs  ->
      FStar_List.fold_right
        (fun b  -> fun e1  -> FStar_TypeChecker_Env.push_bv e1 b) bvs e
let subst_goal:
  FStar_Syntax_Syntax.bv ->
    FStar_Syntax_Syntax.bv ->
      FStar_Syntax_Syntax.subst_elt Prims.list ->
        FStar_Tactics_Types.goal ->
          FStar_Tactics_Types.goal FStar_Pervasives_Native.option
  =
  fun b1  ->
    fun b2  ->
      fun s  ->
        fun g  ->
          let uu____3730 = split_env b1 g.FStar_Tactics_Types.context in
          FStar_Util.map_opt uu____3730
            (fun uu____3754  ->
               match uu____3754 with
               | (e0,bvs) ->
                   let s1 bv =
                     let uu___141_3771 = bv in
                     let uu____3772 =
                       FStar_Syntax_Subst.subst s bv.FStar_Syntax_Syntax.sort in
                     {
                       FStar_Syntax_Syntax.ppname =
                         (uu___141_3771.FStar_Syntax_Syntax.ppname);
                       FStar_Syntax_Syntax.index =
                         (uu___141_3771.FStar_Syntax_Syntax.index);
                       FStar_Syntax_Syntax.sort = uu____3772
                     } in
                   let bvs1 = FStar_List.map s1 bvs in
                   let c = push_bvs e0 (b2 :: bvs1) in
                   let w =
                     FStar_Syntax_Subst.subst s g.FStar_Tactics_Types.witness in
                   let t =
                     FStar_Syntax_Subst.subst s g.FStar_Tactics_Types.goal_ty in
                   let uu___142_3781 = g in
                   {
                     FStar_Tactics_Types.context = c;
                     FStar_Tactics_Types.witness = w;
                     FStar_Tactics_Types.goal_ty = t;
                     FStar_Tactics_Types.opts =
                       (uu___142_3781.FStar_Tactics_Types.opts);
                     FStar_Tactics_Types.is_guard =
                       (uu___142_3781.FStar_Tactics_Types.is_guard)
                   })
let rewrite: FStar_Syntax_Syntax.binder -> Prims.unit tac =
  fun h  ->
    bind cur_goal
      (fun goal  ->
         let uu____3795 = h in
         match uu____3795 with
         | (bv,uu____3799) ->
             mlog
               (fun uu____3803  ->
                  let uu____3804 = FStar_Syntax_Print.bv_to_string bv in
                  let uu____3805 =
                    FStar_Syntax_Print.term_to_string
                      bv.FStar_Syntax_Syntax.sort in
                  FStar_Util.print2 "+++Rewrite %s : %s\n" uu____3804
                    uu____3805)
               (fun uu____3808  ->
                  let uu____3809 =
                    split_env bv goal.FStar_Tactics_Types.context in
                  match uu____3809 with
                  | FStar_Pervasives_Native.None  ->
                      fail "rewrite: binder not found in environment"
                  | FStar_Pervasives_Native.Some (e0,bvs) ->
                      let uu____3838 =
                        destruct_eq bv.FStar_Syntax_Syntax.sort in
                      (match uu____3838 with
                       | FStar_Pervasives_Native.Some (x,e) ->
                           let uu____3853 =
                             let uu____3854 = FStar_Syntax_Subst.compress x in
                             uu____3854.FStar_Syntax_Syntax.n in
                           (match uu____3853 with
                            | FStar_Syntax_Syntax.Tm_name x1 ->
                                let s = [FStar_Syntax_Syntax.NT (x1, e)] in
                                let s1 bv1 =
                                  let uu___143_3867 = bv1 in
                                  let uu____3868 =
                                    FStar_Syntax_Subst.subst s
                                      bv1.FStar_Syntax_Syntax.sort in
                                  {
                                    FStar_Syntax_Syntax.ppname =
                                      (uu___143_3867.FStar_Syntax_Syntax.ppname);
                                    FStar_Syntax_Syntax.index =
                                      (uu___143_3867.FStar_Syntax_Syntax.index);
                                    FStar_Syntax_Syntax.sort = uu____3868
                                  } in
                                let bvs1 = FStar_List.map s1 bvs in
                                let uu____3874 =
                                  let uu___144_3875 = goal in
                                  let uu____3876 = push_bvs e0 (bv :: bvs1) in
                                  let uu____3877 =
                                    FStar_Syntax_Subst.subst s
                                      goal.FStar_Tactics_Types.witness in
                                  let uu____3878 =
                                    FStar_Syntax_Subst.subst s
                                      goal.FStar_Tactics_Types.goal_ty in
                                  {
                                    FStar_Tactics_Types.context = uu____3876;
                                    FStar_Tactics_Types.witness = uu____3877;
                                    FStar_Tactics_Types.goal_ty = uu____3878;
                                    FStar_Tactics_Types.opts =
                                      (uu___144_3875.FStar_Tactics_Types.opts);
                                    FStar_Tactics_Types.is_guard =
                                      (uu___144_3875.FStar_Tactics_Types.is_guard)
                                  } in
                                replace_cur uu____3874
                            | uu____3879 ->
                                fail
                                  "rewrite: Not an equality hypothesis with a variable on the LHS")
                       | uu____3880 ->
                           fail "rewrite: Not an equality hypothesis")))
let rename_to: FStar_Syntax_Syntax.binder -> Prims.string -> Prims.unit tac =
  fun b  ->
    fun s  ->
      bind cur_goal
        (fun goal  ->
           let uu____3907 = b in
           match uu____3907 with
           | (bv,uu____3911) ->
               let bv' =
                 FStar_Syntax_Syntax.freshen_bv
                   (let uu___145_3915 = bv in
                    {
                      FStar_Syntax_Syntax.ppname =
                        (FStar_Ident.mk_ident
                           (s,
                             ((bv.FStar_Syntax_Syntax.ppname).FStar_Ident.idRange)));
                      FStar_Syntax_Syntax.index =
                        (uu___145_3915.FStar_Syntax_Syntax.index);
                      FStar_Syntax_Syntax.sort =
                        (uu___145_3915.FStar_Syntax_Syntax.sort)
                    }) in
               let s1 =
                 let uu____3919 =
                   let uu____3920 =
                     let uu____3927 = FStar_Syntax_Syntax.bv_to_name bv' in
                     (bv, uu____3927) in
                   FStar_Syntax_Syntax.NT uu____3920 in
                 [uu____3919] in
               let uu____3928 = subst_goal bv bv' s1 goal in
               (match uu____3928 with
                | FStar_Pervasives_Native.None  ->
                    fail "rename_to: binder not found in environment"
                | FStar_Pervasives_Native.Some goal1 -> replace_cur goal1))
let binder_retype: FStar_Syntax_Syntax.binder -> Prims.unit tac =
  fun b  ->
    bind cur_goal
      (fun goal  ->
         let uu____3948 = b in
         match uu____3948 with
         | (bv,uu____3952) ->
             let uu____3953 = split_env bv goal.FStar_Tactics_Types.context in
             (match uu____3953 with
              | FStar_Pervasives_Native.None  ->
                  fail "binder_retype: binder is not present in environment"
              | FStar_Pervasives_Native.Some (e0,bvs) ->
                  let uu____3982 = FStar_Syntax_Util.type_u () in
                  (match uu____3982 with
                   | (ty,u) ->
                       let uu____3991 = new_uvar "binder_retype" e0 ty in
                       bind uu____3991
                         (fun t'  ->
                            let bv'' =
                              let uu___146_4001 = bv in
                              {
                                FStar_Syntax_Syntax.ppname =
                                  (uu___146_4001.FStar_Syntax_Syntax.ppname);
                                FStar_Syntax_Syntax.index =
                                  (uu___146_4001.FStar_Syntax_Syntax.index);
                                FStar_Syntax_Syntax.sort = t'
                              } in
                            let s =
                              let uu____4005 =
                                let uu____4006 =
                                  let uu____4013 =
                                    FStar_Syntax_Syntax.bv_to_name bv'' in
                                  (bv, uu____4013) in
                                FStar_Syntax_Syntax.NT uu____4006 in
                              [uu____4005] in
                            let bvs1 =
                              FStar_List.map
                                (fun b1  ->
                                   let uu___147_4021 = b1 in
                                   let uu____4022 =
                                     FStar_Syntax_Subst.subst s
                                       b1.FStar_Syntax_Syntax.sort in
                                   {
                                     FStar_Syntax_Syntax.ppname =
                                       (uu___147_4021.FStar_Syntax_Syntax.ppname);
                                     FStar_Syntax_Syntax.index =
                                       (uu___147_4021.FStar_Syntax_Syntax.index);
                                     FStar_Syntax_Syntax.sort = uu____4022
                                   }) bvs in
                            let env' = push_bvs e0 (bv'' :: bvs1) in
                            bind dismiss
                              (fun uu____4028  ->
                                 let uu____4029 =
                                   let uu____4032 =
                                     let uu____4035 =
                                       let uu___148_4036 = goal in
                                       let uu____4037 =
                                         FStar_Syntax_Subst.subst s
                                           goal.FStar_Tactics_Types.witness in
                                       let uu____4038 =
                                         FStar_Syntax_Subst.subst s
                                           goal.FStar_Tactics_Types.goal_ty in
                                       {
                                         FStar_Tactics_Types.context = env';
                                         FStar_Tactics_Types.witness =
                                           uu____4037;
                                         FStar_Tactics_Types.goal_ty =
                                           uu____4038;
                                         FStar_Tactics_Types.opts =
                                           (uu___148_4036.FStar_Tactics_Types.opts);
                                         FStar_Tactics_Types.is_guard =
                                           (uu___148_4036.FStar_Tactics_Types.is_guard)
                                       } in
                                     [uu____4035] in
                                   add_goals uu____4032 in
                                 bind uu____4029
                                   (fun uu____4041  ->
                                      let uu____4042 =
                                        FStar_Syntax_Util.mk_eq2
                                          (FStar_Syntax_Syntax.U_succ u) ty
                                          bv.FStar_Syntax_Syntax.sort t' in
                                      add_irrelevant_goal
                                        "binder_retype equation" e0
                                        uu____4042
                                        goal.FStar_Tactics_Types.opts))))))
let revert: Prims.unit tac =
  bind cur_goal
    (fun goal  ->
       let uu____4048 =
         FStar_TypeChecker_Env.pop_bv goal.FStar_Tactics_Types.context in
       match uu____4048 with
       | FStar_Pervasives_Native.None  -> fail "Cannot revert; empty context"
       | FStar_Pervasives_Native.Some (x,env') ->
           let typ' =
             let uu____4070 =
               FStar_Syntax_Syntax.mk_Total goal.FStar_Tactics_Types.goal_ty in
             FStar_Syntax_Util.arrow [(x, FStar_Pervasives_Native.None)]
               uu____4070 in
           let w' =
             FStar_Syntax_Util.abs [(x, FStar_Pervasives_Native.None)]
               goal.FStar_Tactics_Types.witness FStar_Pervasives_Native.None in
           replace_cur
             (let uu___149_4104 = goal in
              {
                FStar_Tactics_Types.context = env';
                FStar_Tactics_Types.witness = w';
                FStar_Tactics_Types.goal_ty = typ';
                FStar_Tactics_Types.opts =
                  (uu___149_4104.FStar_Tactics_Types.opts);
                FStar_Tactics_Types.is_guard =
                  (uu___149_4104.FStar_Tactics_Types.is_guard)
              }))
let revert_hd: name -> Prims.unit tac =
  fun x  ->
    bind cur_goal
      (fun goal  ->
         let uu____4116 =
           FStar_TypeChecker_Env.pop_bv goal.FStar_Tactics_Types.context in
         match uu____4116 with
         | FStar_Pervasives_Native.None  ->
             fail "Cannot revert_hd; empty context"
         | FStar_Pervasives_Native.Some (y,env') ->
             if Prims.op_Negation (FStar_Syntax_Syntax.bv_eq x y)
             then
               let uu____4137 = FStar_Syntax_Print.bv_to_string x in
               let uu____4138 = FStar_Syntax_Print.bv_to_string y in
               fail2
                 "Cannot revert_hd %s; head variable mismatch ... egot %s"
                 uu____4137 uu____4138
             else revert)
let clear_top: Prims.unit tac =
  bind cur_goal
    (fun goal  ->
       let uu____4145 =
         FStar_TypeChecker_Env.pop_bv goal.FStar_Tactics_Types.context in
       match uu____4145 with
       | FStar_Pervasives_Native.None  -> fail "Cannot clear; empty context"
       | FStar_Pervasives_Native.Some (x,env') ->
           let fns_ty =
             FStar_Syntax_Free.names goal.FStar_Tactics_Types.goal_ty in
           let uu____4167 = FStar_Util.set_mem x fns_ty in
           if uu____4167
           then fail "Cannot clear; variable appears in goal"
           else
             (let uu____4171 =
                new_uvar "clear_top" env' goal.FStar_Tactics_Types.goal_ty in
              bind uu____4171
                (fun u  ->
                   let uu____4177 =
                     let uu____4178 = trysolve goal u in
                     Prims.op_Negation uu____4178 in
                   if uu____4177
                   then fail "clear: unification failed"
                   else
                     (let new_goal =
                        let uu___150_4183 = goal in
                        let uu____4184 = bnorm env' u in
                        {
                          FStar_Tactics_Types.context = env';
                          FStar_Tactics_Types.witness = uu____4184;
                          FStar_Tactics_Types.goal_ty =
                            (uu___150_4183.FStar_Tactics_Types.goal_ty);
                          FStar_Tactics_Types.opts =
                            (uu___150_4183.FStar_Tactics_Types.opts);
                          FStar_Tactics_Types.is_guard =
                            (uu___150_4183.FStar_Tactics_Types.is_guard)
                        } in
                      bind dismiss (fun uu____4186  -> add_goals [new_goal])))))
let rec clear: FStar_Syntax_Syntax.binder -> Prims.unit tac =
  fun b  ->
    bind cur_goal
      (fun goal  ->
         let uu____4198 =
           FStar_TypeChecker_Env.pop_bv goal.FStar_Tactics_Types.context in
         match uu____4198 with
         | FStar_Pervasives_Native.None  ->
             fail "Cannot clear; empty context"
         | FStar_Pervasives_Native.Some (b',env') ->
             if FStar_Syntax_Syntax.bv_eq (FStar_Pervasives_Native.fst b) b'
             then clear_top
             else
               bind revert
                 (fun uu____4222  ->
                    let uu____4223 = clear b in
                    bind uu____4223
                      (fun uu____4227  ->
                         bind intro (fun uu____4229  -> ret ()))))
let prune: Prims.string -> Prims.unit tac =
  fun s  ->
    bind cur_goal
      (fun g  ->
         let ctx = g.FStar_Tactics_Types.context in
         let ctx' =
           FStar_TypeChecker_Env.rem_proof_ns ctx
             (FStar_Ident.path_of_text s) in
         let g' =
           let uu___151_4246 = g in
           {
             FStar_Tactics_Types.context = ctx';
             FStar_Tactics_Types.witness =
               (uu___151_4246.FStar_Tactics_Types.witness);
             FStar_Tactics_Types.goal_ty =
               (uu___151_4246.FStar_Tactics_Types.goal_ty);
             FStar_Tactics_Types.opts =
               (uu___151_4246.FStar_Tactics_Types.opts);
             FStar_Tactics_Types.is_guard =
               (uu___151_4246.FStar_Tactics_Types.is_guard)
           } in
         bind dismiss (fun uu____4248  -> add_goals [g']))
let addns: Prims.string -> Prims.unit tac =
  fun s  ->
    bind cur_goal
      (fun g  ->
         let ctx = g.FStar_Tactics_Types.context in
         let ctx' =
           FStar_TypeChecker_Env.add_proof_ns ctx
             (FStar_Ident.path_of_text s) in
         let g' =
           let uu___152_4265 = g in
           {
             FStar_Tactics_Types.context = ctx';
             FStar_Tactics_Types.witness =
               (uu___152_4265.FStar_Tactics_Types.witness);
             FStar_Tactics_Types.goal_ty =
               (uu___152_4265.FStar_Tactics_Types.goal_ty);
             FStar_Tactics_Types.opts =
               (uu___152_4265.FStar_Tactics_Types.opts);
             FStar_Tactics_Types.is_guard =
               (uu___152_4265.FStar_Tactics_Types.is_guard)
           } in
         bind dismiss (fun uu____4267  -> add_goals [g']))
let rec mapM: 'a 'b . ('a -> 'b tac) -> 'a Prims.list -> 'b Prims.list tac =
  fun f  ->
    fun l  ->
      match l with
      | [] -> ret []
      | x::xs ->
          let uu____4309 = f x in
          bind uu____4309
            (fun y  ->
               let uu____4317 = mapM f xs in
               bind uu____4317 (fun ys  -> ret (y :: ys)))
let rec tac_fold_env:
  FStar_Tactics_Types.direction ->
    (env -> FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term tac) ->
      env -> FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term tac
  =
  fun d  ->
    fun f  ->
      fun env  ->
        fun t  ->
          let tn =
            let uu____4367 = FStar_Syntax_Subst.compress t in
            uu____4367.FStar_Syntax_Syntax.n in
          let uu____4370 =
            if d = FStar_Tactics_Types.TopDown
            then
              f env
                (let uu___154_4376 = t in
                 {
                   FStar_Syntax_Syntax.n = tn;
                   FStar_Syntax_Syntax.pos =
                     (uu___154_4376.FStar_Syntax_Syntax.pos);
                   FStar_Syntax_Syntax.vars =
                     (uu___154_4376.FStar_Syntax_Syntax.vars)
                 })
            else ret t in
          bind uu____4370
            (fun t1  ->
               let tn1 =
                 match tn with
                 | FStar_Syntax_Syntax.Tm_app (hd1,args) ->
                     let ff = tac_fold_env d f env in
                     let uu____4413 = ff hd1 in
                     bind uu____4413
                       (fun hd2  ->
                          let fa uu____4433 =
                            match uu____4433 with
                            | (a,q) ->
                                let uu____4446 = ff a in
                                bind uu____4446 (fun a1  -> ret (a1, q)) in
                          let uu____4459 = mapM fa args in
                          bind uu____4459
                            (fun args1  ->
                               ret (FStar_Syntax_Syntax.Tm_app (hd2, args1))))
                 | FStar_Syntax_Syntax.Tm_abs (bs,t2,k) ->
                     let uu____4519 = FStar_Syntax_Subst.open_term bs t2 in
                     (match uu____4519 with
                      | (bs1,t') ->
                          let uu____4528 =
                            let uu____4531 =
                              FStar_TypeChecker_Env.push_binders env bs1 in
                            tac_fold_env d f uu____4531 t' in
                          bind uu____4528
                            (fun t''  ->
                               let uu____4535 =
                                 let uu____4536 =
                                   let uu____4553 =
                                     FStar_Syntax_Subst.close_binders bs1 in
                                   let uu____4554 =
                                     FStar_Syntax_Subst.close bs1 t'' in
                                   (uu____4553, uu____4554, k) in
                                 FStar_Syntax_Syntax.Tm_abs uu____4536 in
                               ret uu____4535))
                 | FStar_Syntax_Syntax.Tm_arrow (bs,k) -> ret tn
                 | uu____4575 -> ret tn in
               bind tn1
                 (fun tn2  ->
                    let t' =
                      let uu___153_4582 = t1 in
                      {
                        FStar_Syntax_Syntax.n = tn2;
                        FStar_Syntax_Syntax.pos =
                          (uu___153_4582.FStar_Syntax_Syntax.pos);
                        FStar_Syntax_Syntax.vars =
                          (uu___153_4582.FStar_Syntax_Syntax.vars)
                      } in
                    if d = FStar_Tactics_Types.BottomUp
                    then f env t'
                    else ret t'))
let pointwise_rec:
  FStar_Tactics_Types.proofstate ->
    Prims.unit tac ->
      FStar_Options.optionstate ->
        FStar_TypeChecker_Env.env ->
          FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term tac
  =
  fun ps  ->
    fun tau  ->
      fun opts  ->
        fun env  ->
          fun t  ->
            let uu____4616 = FStar_TypeChecker_TcTerm.tc_term env t in
            match uu____4616 with
            | (t1,lcomp,g) ->
                let uu____4628 =
                  (let uu____4631 =
                     FStar_Syntax_Util.is_pure_or_ghost_lcomp lcomp in
                   Prims.op_Negation uu____4631) ||
                    (let uu____4633 = FStar_TypeChecker_Rel.is_trivial g in
                     Prims.op_Negation uu____4633) in
                if uu____4628
                then ret t1
                else
                  (let typ = lcomp.FStar_Syntax_Syntax.res_typ in
                   let uu____4640 = new_uvar "pointwise_rec" env typ in
                   bind uu____4640
                     (fun ut  ->
                        log ps
                          (fun uu____4651  ->
                             let uu____4652 =
                               FStar_Syntax_Print.term_to_string t1 in
                             let uu____4653 =
                               FStar_Syntax_Print.term_to_string ut in
                             FStar_Util.print2
                               "Pointwise_rec: making equality %s = %s\n"
                               uu____4652 uu____4653);
                        (let uu____4654 =
                           let uu____4657 =
                             let uu____4658 =
                               FStar_TypeChecker_TcTerm.universe_of env typ in
                             FStar_Syntax_Util.mk_eq2 uu____4658 typ t1 ut in
                           add_irrelevant_goal "pointwise_rec equation" env
                             uu____4657 opts in
                         bind uu____4654
                           (fun uu____4661  ->
                              let uu____4662 =
                                bind tau
                                  (fun uu____4667  ->
                                     let ut1 =
                                       FStar_TypeChecker_Normalize.reduce_uvar_solutions
                                         env ut in
                                     ret ut1) in
                              focus uu____4662))))
let pointwise:
  FStar_Tactics_Types.direction -> Prims.unit tac -> Prims.unit tac =
  fun d  ->
    fun tau  ->
      bind get
        (fun ps  ->
           let uu____4692 =
             match ps.FStar_Tactics_Types.goals with
             | g::gs -> (g, gs)
             | [] -> failwith "Pointwise: no goals" in
           match uu____4692 with
           | (g,gs) ->
               let gt1 = g.FStar_Tactics_Types.goal_ty in
               (log ps
                  (fun uu____4729  ->
                     let uu____4730 = FStar_Syntax_Print.term_to_string gt1 in
                     FStar_Util.print1 "Pointwise starting with %s\n"
                       uu____4730);
                bind dismiss_all
                  (fun uu____4733  ->
                     let uu____4734 =
                       tac_fold_env d
                         (pointwise_rec ps tau g.FStar_Tactics_Types.opts)
                         g.FStar_Tactics_Types.context gt1 in
                     bind uu____4734
                       (fun gt'  ->
                          log ps
                            (fun uu____4744  ->
                               let uu____4745 =
                                 FStar_Syntax_Print.term_to_string gt' in
                               FStar_Util.print1
                                 "Pointwise seems to have succeded with %s\n"
                                 uu____4745);
                          (let uu____4746 = push_goals gs in
                           bind uu____4746
                             (fun uu____4750  ->
                                add_goals
                                  [(let uu___155_4752 = g in
                                    {
                                      FStar_Tactics_Types.context =
                                        (uu___155_4752.FStar_Tactics_Types.context);
                                      FStar_Tactics_Types.witness =
                                        (uu___155_4752.FStar_Tactics_Types.witness);
                                      FStar_Tactics_Types.goal_ty = gt';
                                      FStar_Tactics_Types.opts =
                                        (uu___155_4752.FStar_Tactics_Types.opts);
                                      FStar_Tactics_Types.is_guard =
                                        (uu___155_4752.FStar_Tactics_Types.is_guard)
                                    })]))))))
let trefl: Prims.unit tac =
  bind cur_goal
    (fun g  ->
       let uu____4772 =
         FStar_Syntax_Util.un_squash g.FStar_Tactics_Types.goal_ty in
       match uu____4772 with
       | FStar_Pervasives_Native.Some t ->
           let uu____4784 = FStar_Syntax_Util.head_and_args' t in
           (match uu____4784 with
            | (hd1,args) ->
                let uu____4817 =
                  let uu____4830 =
                    let uu____4831 = FStar_Syntax_Util.un_uinst hd1 in
                    uu____4831.FStar_Syntax_Syntax.n in
                  (uu____4830, args) in
                (match uu____4817 with
                 | (FStar_Syntax_Syntax.Tm_fvar
                    fv,uu____4845::(l,uu____4847)::(r,uu____4849)::[]) when
                     FStar_Syntax_Syntax.fv_eq_lid fv
                       FStar_Parser_Const.eq2_lid
                     ->
                     let uu____4896 =
                       let uu____4897 =
                         do_unify g.FStar_Tactics_Types.context l r in
                       Prims.op_Negation uu____4897 in
                     if uu____4896
                     then
                       let uu____4900 =
                         FStar_TypeChecker_Normalize.term_to_string
                           g.FStar_Tactics_Types.context l in
                       let uu____4901 =
                         FStar_TypeChecker_Normalize.term_to_string
                           g.FStar_Tactics_Types.context r in
                       fail2 "trefl: not a trivial equality (%s vs %s)"
                         uu____4900 uu____4901
                     else solve g FStar_Syntax_Util.exp_unit
                 | (hd2,uu____4904) ->
                     let uu____4921 =
                       FStar_TypeChecker_Normalize.term_to_string
                         g.FStar_Tactics_Types.context t in
                     fail1 "trefl: not an equality (%s)" uu____4921))
       | FStar_Pervasives_Native.None  -> fail "not an irrelevant goal")
let dup: Prims.unit tac =
  bind cur_goal
    (fun g  ->
       let uu____4929 =
         new_uvar "dup" g.FStar_Tactics_Types.context
           g.FStar_Tactics_Types.goal_ty in
       bind uu____4929
         (fun u  ->
            let g' =
              let uu___156_4936 = g in
              {
                FStar_Tactics_Types.context =
                  (uu___156_4936.FStar_Tactics_Types.context);
                FStar_Tactics_Types.witness = u;
                FStar_Tactics_Types.goal_ty =
                  (uu___156_4936.FStar_Tactics_Types.goal_ty);
                FStar_Tactics_Types.opts =
                  (uu___156_4936.FStar_Tactics_Types.opts);
                FStar_Tactics_Types.is_guard =
                  (uu___156_4936.FStar_Tactics_Types.is_guard)
              } in
            bind dismiss
              (fun uu____4939  ->
                 let uu____4940 =
                   let uu____4943 =
                     let uu____4944 =
                       FStar_TypeChecker_TcTerm.universe_of
                         g.FStar_Tactics_Types.context
                         g.FStar_Tactics_Types.goal_ty in
                     FStar_Syntax_Util.mk_eq2 uu____4944
                       g.FStar_Tactics_Types.goal_ty u
                       g.FStar_Tactics_Types.witness in
                   add_irrelevant_goal "dup equation"
                     g.FStar_Tactics_Types.context uu____4943
                     g.FStar_Tactics_Types.opts in
                 bind uu____4940
                   (fun uu____4947  ->
                      let uu____4948 = add_goals [g'] in
                      bind uu____4948 (fun uu____4952  -> ret ())))))
let flip: Prims.unit tac =
  bind get
    (fun ps  ->
       match ps.FStar_Tactics_Types.goals with
       | g1::g2::gs ->
           set
             (let uu___157_4969 = ps in
              {
                FStar_Tactics_Types.main_context =
                  (uu___157_4969.FStar_Tactics_Types.main_context);
                FStar_Tactics_Types.main_goal =
                  (uu___157_4969.FStar_Tactics_Types.main_goal);
                FStar_Tactics_Types.all_implicits =
                  (uu___157_4969.FStar_Tactics_Types.all_implicits);
                FStar_Tactics_Types.goals = (g2 :: g1 :: gs);
                FStar_Tactics_Types.smt_goals =
                  (uu___157_4969.FStar_Tactics_Types.smt_goals);
                FStar_Tactics_Types.depth =
                  (uu___157_4969.FStar_Tactics_Types.depth);
                FStar_Tactics_Types.__dump =
                  (uu___157_4969.FStar_Tactics_Types.__dump)
              })
       | uu____4970 -> fail "flip: less than 2 goals")
let later: Prims.unit tac =
  bind get
    (fun ps  ->
       match ps.FStar_Tactics_Types.goals with
       | [] -> ret ()
       | g::gs ->
           set
             (let uu___158_4985 = ps in
              {
                FStar_Tactics_Types.main_context =
                  (uu___158_4985.FStar_Tactics_Types.main_context);
                FStar_Tactics_Types.main_goal =
                  (uu___158_4985.FStar_Tactics_Types.main_goal);
                FStar_Tactics_Types.all_implicits =
                  (uu___158_4985.FStar_Tactics_Types.all_implicits);
                FStar_Tactics_Types.goals = (FStar_List.append gs [g]);
                FStar_Tactics_Types.smt_goals =
                  (uu___158_4985.FStar_Tactics_Types.smt_goals);
                FStar_Tactics_Types.depth =
                  (uu___158_4985.FStar_Tactics_Types.depth);
                FStar_Tactics_Types.__dump =
                  (uu___158_4985.FStar_Tactics_Types.__dump)
              }))
let qed: Prims.unit tac =
  bind get
    (fun ps  ->
       match ps.FStar_Tactics_Types.goals with
       | [] -> ret ()
       | uu____4992 -> fail "Not done!")
let cases:
  FStar_Syntax_Syntax.term ->
    (FStar_Syntax_Syntax.term,FStar_Syntax_Syntax.term)
      FStar_Pervasives_Native.tuple2 tac
  =
  fun t  ->
    bind cur_goal
      (fun g  ->
         let uu____5034 =
           (g.FStar_Tactics_Types.context).FStar_TypeChecker_Env.type_of
             g.FStar_Tactics_Types.context t in
         match uu____5034 with
         | (t1,typ,guard) ->
             let uu____5050 = FStar_Syntax_Util.head_and_args typ in
             (match uu____5050 with
              | (hd1,args) ->
                  let uu____5093 =
                    let uu____5106 =
                      let uu____5107 = FStar_Syntax_Util.un_uinst hd1 in
                      uu____5107.FStar_Syntax_Syntax.n in
                    (uu____5106, args) in
                  (match uu____5093 with
                   | (FStar_Syntax_Syntax.Tm_fvar
                      fv,(p,uu____5126)::(q,uu____5128)::[]) when
                       FStar_Syntax_Syntax.fv_eq_lid fv
                         FStar_Parser_Const.or_lid
                       ->
                       let v_p =
                         FStar_Syntax_Syntax.new_bv
                           FStar_Pervasives_Native.None p in
                       let v_q =
                         FStar_Syntax_Syntax.new_bv
                           FStar_Pervasives_Native.None q in
                       let g1 =
                         let uu___159_5166 = g in
                         let uu____5167 =
                           FStar_TypeChecker_Env.push_bv
                             g.FStar_Tactics_Types.context v_p in
                         {
                           FStar_Tactics_Types.context = uu____5167;
                           FStar_Tactics_Types.witness =
                             (uu___159_5166.FStar_Tactics_Types.witness);
                           FStar_Tactics_Types.goal_ty =
                             (uu___159_5166.FStar_Tactics_Types.goal_ty);
                           FStar_Tactics_Types.opts =
                             (uu___159_5166.FStar_Tactics_Types.opts);
                           FStar_Tactics_Types.is_guard =
                             (uu___159_5166.FStar_Tactics_Types.is_guard)
                         } in
                       let g2 =
                         let uu___160_5169 = g in
                         let uu____5170 =
                           FStar_TypeChecker_Env.push_bv
                             g.FStar_Tactics_Types.context v_q in
                         {
                           FStar_Tactics_Types.context = uu____5170;
                           FStar_Tactics_Types.witness =
                             (uu___160_5169.FStar_Tactics_Types.witness);
                           FStar_Tactics_Types.goal_ty =
                             (uu___160_5169.FStar_Tactics_Types.goal_ty);
                           FStar_Tactics_Types.opts =
                             (uu___160_5169.FStar_Tactics_Types.opts);
                           FStar_Tactics_Types.is_guard =
                             (uu___160_5169.FStar_Tactics_Types.is_guard)
                         } in
                       bind dismiss
                         (fun uu____5177  ->
                            let uu____5178 = add_goals [g1; g2] in
                            bind uu____5178
                              (fun uu____5187  ->
                                 let uu____5188 =
                                   let uu____5193 =
                                     FStar_Syntax_Syntax.bv_to_name v_p in
                                   let uu____5194 =
                                     FStar_Syntax_Syntax.bv_to_name v_q in
                                   (uu____5193, uu____5194) in
                                 ret uu____5188))
                   | uu____5199 ->
                       let uu____5212 =
                         FStar_TypeChecker_Normalize.term_to_string
                           g.FStar_Tactics_Types.context typ in
                       fail1 "Not a disjunction: %s" uu____5212)))
let set_options: Prims.string -> Prims.unit tac =
  fun s  ->
    bind cur_goal
      (fun g  ->
         FStar_Options.push ();
         (let uu____5235 = FStar_Util.smap_copy g.FStar_Tactics_Types.opts in
          FStar_Options.set uu____5235);
         (let res = FStar_Options.set_options FStar_Options.Set s in
          let opts' = FStar_Options.peek () in
          FStar_Options.pop ();
          (match res with
           | FStar_Getopt.Success  ->
               let g' =
                 let uu___161_5242 = g in
                 {
                   FStar_Tactics_Types.context =
                     (uu___161_5242.FStar_Tactics_Types.context);
                   FStar_Tactics_Types.witness =
                     (uu___161_5242.FStar_Tactics_Types.witness);
                   FStar_Tactics_Types.goal_ty =
                     (uu___161_5242.FStar_Tactics_Types.goal_ty);
                   FStar_Tactics_Types.opts = opts';
                   FStar_Tactics_Types.is_guard =
                     (uu___161_5242.FStar_Tactics_Types.is_guard)
                 } in
               replace_cur g'
           | FStar_Getopt.Error err1 ->
               fail2 "Setting options `%s` failed: %s" s err1
           | FStar_Getopt.Help  ->
               fail1 "Setting options `%s` failed (got `Help`?)" s)))
let cur_env: FStar_TypeChecker_Env.env tac =
  bind cur_goal
    (fun g  -> FStar_All.pipe_left ret g.FStar_Tactics_Types.context)
let cur_goal': FStar_Syntax_Syntax.typ tac =
  bind cur_goal
    (fun g  -> FStar_All.pipe_left ret g.FStar_Tactics_Types.goal_ty)
let cur_witness: FStar_Syntax_Syntax.term tac =
  bind cur_goal
    (fun g  -> FStar_All.pipe_left ret g.FStar_Tactics_Types.witness)
let unquote:
  FStar_Syntax_Syntax.term ->
    FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term tac
  =
  fun ty  ->
    fun tm  ->
      bind cur_goal
        (fun goal  ->
           let env =
             FStar_TypeChecker_Env.set_expected_typ
               goal.FStar_Tactics_Types.context ty in
           let uu____5283 =
             (goal.FStar_Tactics_Types.context).FStar_TypeChecker_Env.type_of
               env tm in
           match uu____5283 with
           | (tm1,typ,guard) ->
               (FStar_TypeChecker_Rel.force_trivial_guard env guard; ret tm1))
let uvar_env:
  env ->
    FStar_Syntax_Syntax.typ FStar_Pervasives_Native.option ->
      FStar_Syntax_Syntax.term tac
  =
  fun env  ->
    fun ty  ->
      let uu____5312 =
        match ty with
        | FStar_Pervasives_Native.Some ty1 -> ret ty1
        | FStar_Pervasives_Native.None  ->
            let uu____5318 =
              let uu____5319 = FStar_Syntax_Util.type_u () in
              FStar_All.pipe_left FStar_Pervasives_Native.fst uu____5319 in
            new_uvar "uvar_env.2" env uu____5318 in
      bind uu____5312
        (fun typ  ->
           let uu____5331 = new_uvar "uvar_env" env typ in
           bind uu____5331 (fun t  -> ret t))
let unify:
  FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term -> Prims.bool tac =
  fun t1  ->
    fun t2  ->
      bind get
        (fun ps  ->
           let uu____5351 =
             do_unify ps.FStar_Tactics_Types.main_context t1 t2 in
           ret uu____5351)
let launch_process:
  Prims.string -> Prims.string -> Prims.string -> Prims.string tac =
  fun prog  ->
    fun args  ->
      fun input  ->
        bind idtac
          (fun uu____5371  ->
             let uu____5372 = FStar_Options.unsafe_tactic_exec () in
             if uu____5372
             then
               let s =
                 FStar_Util.launch_process true "tactic_launch" prog args
                   input (fun uu____5378  -> fun uu____5379  -> false) in
               ret s
             else
               fail
                 "launch_process: will not run anything unless --unsafe_tactic_exec is provided")
let goal_of_goal_ty:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
      (FStar_Tactics_Types.goal,FStar_TypeChecker_Env.guard_t)
        FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun typ  ->
      let uu____5401 =
        FStar_TypeChecker_Util.new_implicit_var "proofstate_of_goal_ty"
          typ.FStar_Syntax_Syntax.pos env typ in
      match uu____5401 with
      | (u,uu____5419,g_u) ->
          let g =
            let uu____5434 = FStar_Options.peek () in
            {
              FStar_Tactics_Types.context = env;
              FStar_Tactics_Types.witness = u;
              FStar_Tactics_Types.goal_ty = typ;
              FStar_Tactics_Types.opts = uu____5434;
              FStar_Tactics_Types.is_guard = false
            } in
          (g, g_u)
let proofstate_of_goal_ty:
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
      (FStar_Tactics_Types.proofstate,FStar_Syntax_Syntax.term)
        FStar_Pervasives_Native.tuple2
  =
  fun env  ->
    fun typ  ->
      let uu____5451 = goal_of_goal_ty env typ in
      match uu____5451 with
      | (g,g_u) ->
          let ps =
            {
              FStar_Tactics_Types.main_context = env;
              FStar_Tactics_Types.main_goal = g;
              FStar_Tactics_Types.all_implicits =
                (g_u.FStar_TypeChecker_Env.implicits);
              FStar_Tactics_Types.goals = [g];
              FStar_Tactics_Types.smt_goals = [];
              FStar_Tactics_Types.depth = (Prims.parse_int "0");
              FStar_Tactics_Types.__dump = dump_proofstate
            } in
          (ps, (g.FStar_Tactics_Types.witness))