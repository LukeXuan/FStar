open Prims
type lcomp_with_binder =
  (FStar_Syntax_Syntax.bv FStar_Pervasives_Native.option *
    FStar_TypeChecker_Common.lcomp)
let rec (elaborate_pat :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.pat -> FStar_Syntax_Syntax.pat)
  =
  fun env ->
    fun p ->
      let maybe_dot inaccessible a r =
        if inaccessible
        then
          FStar_Syntax_Syntax.withinfo
            (FStar_Syntax_Syntax.Pat_dot_term FStar_Pervasives_Native.None) r
        else FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_var a) r in
      match p.FStar_Syntax_Syntax.v with
      | FStar_Syntax_Syntax.Pat_cons
          ({ FStar_Syntax_Syntax.fv_name = uu___;
             FStar_Syntax_Syntax.fv_delta = uu___1;
             FStar_Syntax_Syntax.fv_qual = FStar_Pervasives_Native.Some
               (FStar_Syntax_Syntax.Unresolved_constructor uu___2);_},
           uu___3, uu___4)
          -> p
      | FStar_Syntax_Syntax.Pat_cons (fv, us_opt, pats) ->
          let pats1 =
            FStar_Compiler_List.map
              (fun uu___ ->
                 match uu___ with
                 | (p1, imp) ->
                     let uu___1 = elaborate_pat env p1 in (uu___1, imp)) pats in
          let uu___ =
            FStar_TypeChecker_Env.lookup_datacon env
              (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v in
          (match uu___ with
           | (uu___1, t) ->
               let uu___2 = FStar_Syntax_Util.arrow_formals t in
               (match uu___2 with
                | (f, uu___3) ->
                    let rec aux formals pats2 =
                      match (formals, pats2) with
                      | ([], []) -> []
                      | ([], uu___4::uu___5) ->
                          let uu___6 =
                            FStar_Ident.range_of_lid
                              (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v in
                          FStar_Errors.raise_error
                            (FStar_Errors_Codes.Fatal_TooManyPatternArguments,
                              "Too many pattern arguments") uu___6
                      | (uu___4::uu___5, []) ->
                          FStar_Compiler_List.map
                            (fun fml ->
                               let uu___6 =
                                 ((fml.FStar_Syntax_Syntax.binder_bv),
                                   (fml.FStar_Syntax_Syntax.binder_qual)) in
                               match uu___6 with
                               | (t1, imp) ->
                                   (match imp with
                                    | FStar_Pervasives_Native.Some
                                        (FStar_Syntax_Syntax.Implicit
                                        inaccessible) ->
                                        let a =
                                          let uu___7 =
                                            let uu___8 =
                                              FStar_Syntax_Syntax.range_of_bv
                                                t1 in
                                            FStar_Pervasives_Native.Some
                                              uu___8 in
                                          FStar_Syntax_Syntax.new_bv uu___7
                                            FStar_Syntax_Syntax.tun in
                                        let r =
                                          FStar_Ident.range_of_lid
                                            (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v in
                                        let uu___7 =
                                          maybe_dot inaccessible a r in
                                        (uu___7, true)
                                    | uu___7 ->
                                        let uu___8 =
                                          let uu___9 =
                                            let uu___10 =
                                              FStar_Syntax_Print.pat_to_string
                                                p in
                                            FStar_Compiler_Util.format1
                                              "Insufficient pattern arguments (%s)"
                                              uu___10 in
                                          (FStar_Errors_Codes.Fatal_InsufficientPatternArguments,
                                            uu___9) in
                                        let uu___9 =
                                          FStar_Ident.range_of_lid
                                            (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v in
                                        FStar_Errors.raise_error uu___8
                                          uu___9)) formals
                      | (f1::formals', (p1, p_imp)::pats') ->
                          (match ((f1.FStar_Syntax_Syntax.binder_bv),
                                   (f1.FStar_Syntax_Syntax.binder_qual))
                           with
                           | (uu___4, FStar_Pervasives_Native.Some
                              (FStar_Syntax_Syntax.Implicit inaccessible))
                               when inaccessible && p_imp ->
                               (match p1.FStar_Syntax_Syntax.v with
                                | FStar_Syntax_Syntax.Pat_dot_term uu___5 ->
                                    let uu___6 = aux formals' pats' in
                                    (p1, true) :: uu___6
                                | FStar_Syntax_Syntax.Pat_var v when
                                    let uu___5 =
                                      FStar_Ident.string_of_id
                                        v.FStar_Syntax_Syntax.ppname in
                                    uu___5 = FStar_Ident.reserved_prefix ->
                                    let a =
                                      FStar_Syntax_Syntax.new_bv
                                        (FStar_Pervasives_Native.Some
                                           (p1.FStar_Syntax_Syntax.p))
                                        FStar_Syntax_Syntax.tun in
                                    let p2 =
                                      let uu___5 =
                                        FStar_Ident.range_of_lid
                                          (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v in
                                      maybe_dot inaccessible a uu___5 in
                                    let uu___5 = aux formals' pats' in
                                    (p2, true) :: uu___5
                                | uu___5 ->
                                    let uu___6 =
                                      let uu___7 =
                                        let uu___8 =
                                          FStar_Syntax_Print.pat_to_string p1 in
                                        FStar_Compiler_Util.format1
                                          "This pattern (%s) binds an inaccesible argument; use a wildcard ('_') pattern"
                                          uu___8 in
                                      (FStar_Errors_Codes.Fatal_InsufficientPatternArguments,
                                        uu___7) in
                                    FStar_Errors.raise_error uu___6
                                      p1.FStar_Syntax_Syntax.p)
                           | (uu___4, FStar_Pervasives_Native.Some
                              (FStar_Syntax_Syntax.Implicit uu___5)) when
                               p_imp ->
                               let uu___6 = aux formals' pats' in (p1, true)
                                 :: uu___6
                           | (uu___4, FStar_Pervasives_Native.Some
                              (FStar_Syntax_Syntax.Implicit inaccessible)) ->
                               let a =
                                 FStar_Syntax_Syntax.new_bv
                                   (FStar_Pervasives_Native.Some
                                      (p1.FStar_Syntax_Syntax.p))
                                   FStar_Syntax_Syntax.tun in
                               let p2 =
                                 let uu___5 =
                                   FStar_Ident.range_of_lid
                                     (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v in
                                 maybe_dot inaccessible a uu___5 in
                               let uu___5 = aux formals' pats2 in (p2, true)
                                 :: uu___5
                           | (uu___4, imp) ->
                               let uu___5 =
                                 let uu___6 =
                                   FStar_Syntax_Syntax.is_bqual_implicit imp in
                                 (p1, uu___6) in
                               let uu___6 = aux formals' pats' in uu___5 ::
                                 uu___6) in
                    let uu___4 =
                      let uu___5 =
                        let uu___6 = aux f pats1 in (fv, us_opt, uu___6) in
                      FStar_Syntax_Syntax.Pat_cons uu___5 in
                    {
                      FStar_Syntax_Syntax.v = uu___4;
                      FStar_Syntax_Syntax.p = (p.FStar_Syntax_Syntax.p)
                    }))
      | uu___ -> p
exception Raw_pat_cannot_be_translated 
let (uu___is_Raw_pat_cannot_be_translated : Prims.exn -> Prims.bool) =
  fun projectee ->
    match projectee with
    | Raw_pat_cannot_be_translated -> true
    | uu___ -> false
let (raw_pat_as_exp :
  FStar_TypeChecker_Env.env ->
    FStar_Syntax_Syntax.pat ->
      (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.bv Prims.list)
        FStar_Pervasives_Native.option)
  =
  fun env ->
    fun p ->
      let rec aux bs p1 =
        match p1.FStar_Syntax_Syntax.v with
        | FStar_Syntax_Syntax.Pat_constant c ->
            let e =
              match c with
              | FStar_Const.Const_int (repr, FStar_Pervasives_Native.Some sw)
                  ->
                  FStar_ToSyntax_ToSyntax.desugar_machine_integer
                    env.FStar_TypeChecker_Env.dsenv repr sw
                    p1.FStar_Syntax_Syntax.p
              | uu___ ->
                  FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_constant c)
                    p1.FStar_Syntax_Syntax.p in
            (e, bs)
        | FStar_Syntax_Syntax.Pat_dot_term eopt ->
            (match eopt with
             | FStar_Pervasives_Native.None ->
                 FStar_Compiler_Effect.raise Raw_pat_cannot_be_translated
             | FStar_Pervasives_Native.Some e ->
                 let uu___ = FStar_Syntax_Subst.compress e in (uu___, bs))
        | FStar_Syntax_Syntax.Pat_var x ->
            let uu___ =
              FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_name x)
                p1.FStar_Syntax_Syntax.p in
            (uu___, (x :: bs))
        | FStar_Syntax_Syntax.Pat_cons (fv, us_opt, pats) ->
            let uu___ =
              FStar_Compiler_List.fold_right
                (fun uu___1 ->
                   fun uu___2 ->
                     match (uu___1, uu___2) with
                     | ((p2, i), (args, bs1)) ->
                         let uu___3 = aux bs1 p2 in
                         (match uu___3 with
                          | (ep, bs2) ->
                              let uu___4 =
                                let uu___5 =
                                  let uu___6 =
                                    FStar_Syntax_Syntax.as_aqual_implicit i in
                                  (ep, uu___6) in
                                uu___5 :: args in
                              (uu___4, bs2))) pats ([], bs) in
            (match uu___ with
             | (args, bs1) ->
                 let hd = FStar_Syntax_Syntax.fv_to_tm fv in
                 let hd1 =
                   match us_opt with
                   | FStar_Pervasives_Native.None -> hd
                   | FStar_Pervasives_Native.Some us ->
                       FStar_Syntax_Syntax.mk_Tm_uinst hd us in
                 let e =
                   FStar_Syntax_Syntax.mk_Tm_app hd1 args
                     p1.FStar_Syntax_Syntax.p in
                 (e, bs1)) in
      try
        (fun uu___ ->
           match () with
           | () ->
               let uu___1 = aux [] p in FStar_Pervasives_Native.Some uu___1)
          ()
      with | Raw_pat_cannot_be_translated -> FStar_Pervasives_Native.None
let (pat_as_exp :
  Prims.bool ->
    Prims.bool ->
      FStar_TypeChecker_Env.env ->
        FStar_Syntax_Syntax.pat ->
          (FStar_Syntax_Syntax.bv Prims.list * FStar_Syntax_Syntax.term *
            FStar_TypeChecker_Common.guard_t * FStar_Syntax_Syntax.pat))
  =
  fun introduce_bv_uvars ->
    fun inst_pat_cons_univs ->
      fun env ->
        fun p ->
          let intro_bv env1 x =
            if Prims.op_Negation introduce_bv_uvars
            then
              ({
                 FStar_Syntax_Syntax.ppname = (x.FStar_Syntax_Syntax.ppname);
                 FStar_Syntax_Syntax.index = (x.FStar_Syntax_Syntax.index);
                 FStar_Syntax_Syntax.sort = FStar_Syntax_Syntax.tun
               }, FStar_TypeChecker_Env.trivial_guard, env1)
            else
              (let uu___1 = FStar_Syntax_Util.type_u () in
               match uu___1 with
               | (t, uu___2) ->
                   let uu___3 =
                     let uu___4 = FStar_Syntax_Syntax.range_of_bv x in
                     FStar_TypeChecker_Env.new_implicit_var_aux
                       "pattern bv type" uu___4 env1 t
                       (FStar_Syntax_Syntax.Allow_untyped "pattern bv type")
                       FStar_Pervasives_Native.None in
                   (match uu___3 with
                    | (t_x, uu___4, guard) ->
                        let x1 =
                          {
                            FStar_Syntax_Syntax.ppname =
                              (x.FStar_Syntax_Syntax.ppname);
                            FStar_Syntax_Syntax.index =
                              (x.FStar_Syntax_Syntax.index);
                            FStar_Syntax_Syntax.sort = t_x
                          } in
                        let uu___5 = FStar_TypeChecker_Env.push_bv env1 x1 in
                        (x1, guard, uu___5))) in
          let rec pat_as_arg_with_env env1 p1 =
            match p1.FStar_Syntax_Syntax.v with
            | FStar_Syntax_Syntax.Pat_constant c ->
                let e =
                  match c with
                  | FStar_Const.Const_int
                      (repr, FStar_Pervasives_Native.Some sw) ->
                      FStar_ToSyntax_ToSyntax.desugar_machine_integer
                        env1.FStar_TypeChecker_Env.dsenv repr sw
                        p1.FStar_Syntax_Syntax.p
                  | uu___ ->
                      FStar_Syntax_Syntax.mk
                        (FStar_Syntax_Syntax.Tm_constant c)
                        p1.FStar_Syntax_Syntax.p in
                ([], [], [], env1, e, FStar_TypeChecker_Common.trivial_guard,
                  p1)
            | FStar_Syntax_Syntax.Pat_dot_term eopt ->
                (match eopt with
                 | FStar_Pervasives_Native.None ->
                     ((let uu___1 =
                         FStar_TypeChecker_Env.debug env1
                           (FStar_Options.Other "Patterns") in
                       if uu___1
                       then
                         (if
                            Prims.op_Negation
                              env1.FStar_TypeChecker_Env.phase1
                          then
                            let uu___2 = FStar_Syntax_Print.pat_to_string p1 in
                            FStar_Compiler_Util.print1
                              "Found a non-instantiated dot pattern in phase2 (%s)\n"
                              uu___2
                          else ())
                       else ());
                      (let uu___1 = FStar_Syntax_Util.type_u () in
                       match uu___1 with
                       | (k, uu___2) ->
                           let uu___3 =
                             FStar_TypeChecker_Env.new_implicit_var_aux
                               "pat_dot_term type" p1.FStar_Syntax_Syntax.p
                               env1 k
                               (FStar_Syntax_Syntax.Allow_ghost
                                  "pat dot term type")
                               FStar_Pervasives_Native.None in
                           (match uu___3 with
                            | (t, uu___4, g) ->
                                let uu___5 =
                                  FStar_TypeChecker_Env.new_implicit_var_aux
                                    "pat_dot_term" p1.FStar_Syntax_Syntax.p
                                    env1 t
                                    (FStar_Syntax_Syntax.Allow_ghost
                                       "pat dot term")
                                    FStar_Pervasives_Native.None in
                                (match uu___5 with
                                 | (e, uu___6, g') ->
                                     let p2 =
                                       {
                                         FStar_Syntax_Syntax.v =
                                           (FStar_Syntax_Syntax.Pat_dot_term
                                              (FStar_Pervasives_Native.Some e));
                                         FStar_Syntax_Syntax.p =
                                           (p1.FStar_Syntax_Syntax.p)
                                       } in
                                     let uu___7 =
                                       FStar_TypeChecker_Common.conj_guard g
                                         g' in
                                     ([], [], [], env1, e, uu___7, p2)))))
                 | FStar_Pervasives_Native.Some e ->
                     ([], [], [], env1, e,
                       FStar_TypeChecker_Env.trivial_guard, p1))
            | FStar_Syntax_Syntax.Pat_var x ->
                let uu___ = intro_bv env1 x in
                (match uu___ with
                 | (x1, g, env2) ->
                     let e =
                       FStar_Syntax_Syntax.mk
                         (FStar_Syntax_Syntax.Tm_name x1)
                         p1.FStar_Syntax_Syntax.p in
                     ([x1], [x1], [], env2, e, g, p1))
            | FStar_Syntax_Syntax.Pat_cons (fv, us_opt, pats) ->
                let uu___ =
                  FStar_Compiler_List.fold_left
                    (fun uu___1 ->
                       fun uu___2 ->
                         match (uu___1, uu___2) with
                         | ((b, a, w, env2, args, guard, pats1), (p2, imp))
                             ->
                             let uu___3 = pat_as_arg_with_env env2 p2 in
                             (match uu___3 with
                              | (b', a', w', env3, te, guard', pat) ->
                                  let arg =
                                    if imp
                                    then FStar_Syntax_Syntax.iarg te
                                    else FStar_Syntax_Syntax.as_arg te in
                                  let uu___4 =
                                    FStar_TypeChecker_Common.conj_guard guard
                                      guard' in
                                  ((b' :: b), (a' :: a), (w' :: w), env3,
                                    (arg :: args), uu___4, ((pat, imp) ::
                                    pats1))))
                    ([], [], [], env1, [],
                      FStar_TypeChecker_Common.trivial_guard, []) pats in
                (match uu___ with
                 | (b, a, w, env2, args, guard, pats1) ->
                     let inst_head hd us_opt1 =
                       match us_opt1 with
                       | FStar_Pervasives_Native.None -> hd
                       | FStar_Pervasives_Native.Some us ->
                           FStar_Syntax_Syntax.mk_Tm_uinst hd us in
                     let uu___1 =
                       let hd = FStar_Syntax_Syntax.fv_to_tm fv in
                       if
                         (Prims.op_Negation inst_pat_cons_univs) ||
                           (FStar_Pervasives_Native.uu___is_Some us_opt)
                       then
                         let uu___2 = inst_head hd us_opt in (uu___2, us_opt)
                       else
                         (let uu___3 =
                            let uu___4 = FStar_Syntax_Syntax.lid_of_fv fv in
                            FStar_TypeChecker_Env.lookup_datacon env2 uu___4 in
                          match uu___3 with
                          | (us, uu___4) ->
                              if
                                (FStar_Compiler_List.length us) =
                                  Prims.int_zero
                              then (hd, (FStar_Pervasives_Native.Some []))
                              else
                                (let uu___6 =
                                   FStar_Syntax_Syntax.mk_Tm_uinst hd us in
                                 (uu___6, (FStar_Pervasives_Native.Some us)))) in
                     (match uu___1 with
                      | (hd, us_opt1) ->
                          let e =
                            FStar_Syntax_Syntax.mk_Tm_app hd
                              (FStar_Compiler_List.rev args)
                              p1.FStar_Syntax_Syntax.p in
                          ((FStar_Compiler_List.flatten
                              (FStar_Compiler_List.rev b)),
                            (FStar_Compiler_List.flatten
                               (FStar_Compiler_List.rev a)),
                            (FStar_Compiler_List.flatten
                               (FStar_Compiler_List.rev w)), env2, e, guard,
                            {
                              FStar_Syntax_Syntax.v =
                                (FStar_Syntax_Syntax.Pat_cons
                                   (fv, us_opt1,
                                     (FStar_Compiler_List.rev pats1)));
                              FStar_Syntax_Syntax.p =
                                (p1.FStar_Syntax_Syntax.p)
                            }))) in
          let one_pat env1 p1 =
            let p2 = elaborate_pat env1 p1 in
            let uu___ = pat_as_arg_with_env env1 p2 in
            match uu___ with
            | (b, a, w, env2, arg, guard, p3) ->
                let uu___1 =
                  FStar_Compiler_Util.find_dup FStar_Syntax_Syntax.bv_eq b in
                (match uu___1 with
                 | FStar_Pervasives_Native.Some x ->
                     let m = FStar_Syntax_Print.bv_to_string x in
                     let err =
                       let uu___2 =
                         FStar_Compiler_Util.format1
                           "The pattern variable \"%s\" was used more than once"
                           m in
                       (FStar_Errors_Codes.Fatal_NonLinearPatternVars,
                         uu___2) in
                     FStar_Errors.raise_error err p3.FStar_Syntax_Syntax.p
                 | uu___2 -> (b, a, w, arg, guard, p3)) in
          let uu___ = one_pat env p in
          match uu___ with
          | (b, uu___1, uu___2, tm, guard, p1) -> (b, tm, guard, p1)