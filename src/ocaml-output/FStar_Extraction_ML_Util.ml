open Prims
let pruneNones:
  'a . 'a FStar_Pervasives_Native.option Prims.list -> 'a Prims.list =
  fun l  ->
    FStar_List.fold_right
      (fun x  ->
         fun ll  ->
           match x with
           | FStar_Pervasives_Native.Some xs -> xs :: ll
           | FStar_Pervasives_Native.None  -> ll) l []
let mlconst_of_const:
  FStar_Const.sconst -> FStar_Extraction_ML_Syntax.mlconstant =
  fun sctt  ->
    match sctt with
    | FStar_Const.Const_range uu____40 -> failwith "Unsupported constant"
    | FStar_Const.Const_effect  -> failwith "Unsupported constant"
    | FStar_Const.Const_unit  -> FStar_Extraction_ML_Syntax.MLC_Unit
    | FStar_Const.Const_char c -> FStar_Extraction_ML_Syntax.MLC_Char c
    | FStar_Const.Const_int (s,i) ->
        FStar_Extraction_ML_Syntax.MLC_Int (s, i)
    | FStar_Const.Const_bool b -> FStar_Extraction_ML_Syntax.MLC_Bool b
    | FStar_Const.Const_float d -> FStar_Extraction_ML_Syntax.MLC_Float d
    | FStar_Const.Const_bytearray (bytes,uu____65) ->
        FStar_Extraction_ML_Syntax.MLC_Bytes bytes
    | FStar_Const.Const_string (s,uu____71) ->
        FStar_Extraction_ML_Syntax.MLC_String s
    | FStar_Const.Const_reify  ->
        failwith "Unhandled constant: reify/reflect"
    | FStar_Const.Const_reflect uu____72 ->
        failwith "Unhandled constant: reify/reflect"
let mlconst_of_const':
  FStar_Range.range ->
    FStar_Const.sconst -> FStar_Extraction_ML_Syntax.mlconstant
  =
  fun p  ->
    fun c  ->
      try mlconst_of_const c
      with
      | uu____87 ->
          let uu____88 =
            let uu____89 = FStar_Range.string_of_range p in
            let uu____90 = FStar_Syntax_Print.const_to_string c in
            FStar_Util.format2 "(%s) Failed to translate constant %s "
              uu____89 uu____90 in
          failwith uu____88
let rec subst_aux:
  (FStar_Extraction_ML_Syntax.mlident,FStar_Extraction_ML_Syntax.mlty)
    FStar_Pervasives_Native.tuple2 Prims.list ->
    FStar_Extraction_ML_Syntax.mlty -> FStar_Extraction_ML_Syntax.mlty
  =
  fun subst1  ->
    fun t  ->
      match t with
      | FStar_Extraction_ML_Syntax.MLTY_Var x ->
          let uu____112 =
            FStar_Util.find_opt
              (fun uu____126  ->
                 match uu____126 with | (y,uu____132) -> y = x) subst1 in
          (match uu____112 with
           | FStar_Pervasives_Native.Some ts ->
               FStar_Pervasives_Native.snd ts
           | FStar_Pervasives_Native.None  -> t)
      | FStar_Extraction_ML_Syntax.MLTY_Fun (t1,f,t2) ->
          let uu____149 =
            let uu____156 = subst_aux subst1 t1 in
            let uu____157 = subst_aux subst1 t2 in (uu____156, f, uu____157) in
          FStar_Extraction_ML_Syntax.MLTY_Fun uu____149
      | FStar_Extraction_ML_Syntax.MLTY_Named (args,path) ->
          let uu____164 =
            let uu____171 = FStar_List.map (subst_aux subst1) args in
            (uu____171, path) in
          FStar_Extraction_ML_Syntax.MLTY_Named uu____164
      | FStar_Extraction_ML_Syntax.MLTY_Tuple ts ->
          let uu____179 = FStar_List.map (subst_aux subst1) ts in
          FStar_Extraction_ML_Syntax.MLTY_Tuple uu____179
      | FStar_Extraction_ML_Syntax.MLTY_Top  ->
          FStar_Extraction_ML_Syntax.MLTY_Top
let try_subst:
  FStar_Extraction_ML_Syntax.mltyscheme ->
    FStar_Extraction_ML_Syntax.mlty Prims.list ->
      FStar_Extraction_ML_Syntax.mlty FStar_Pervasives_Native.option
  =
  fun uu____192  ->
    fun args  ->
      match uu____192 with
      | (formals,t) ->
          if (FStar_List.length formals) <> (FStar_List.length args)
          then FStar_Pervasives_Native.None
          else
            (let uu____203 =
               let uu____204 = FStar_List.zip formals args in
               subst_aux uu____204 t in
             FStar_Pervasives_Native.Some uu____203)
let subst:
  FStar_Extraction_ML_Syntax.mltyscheme ->
    FStar_Extraction_ML_Syntax.mlty Prims.list ->
      FStar_Extraction_ML_Syntax.mlty
  =
  fun ts  ->
    fun args  ->
      let uu____223 = try_subst ts args in
      match uu____223 with
      | FStar_Pervasives_Native.None  ->
          failwith
            "Substitution must be fully applied (see GitHub issue #490)"
      | FStar_Pervasives_Native.Some t -> t
let udelta_unfold:
  FStar_Extraction_ML_UEnv.env ->
    FStar_Extraction_ML_Syntax.mlty ->
      FStar_Extraction_ML_Syntax.mlty FStar_Pervasives_Native.option
  =
  fun g  ->
    fun uu___147_236  ->
      match uu___147_236 with
      | FStar_Extraction_ML_Syntax.MLTY_Named (args,n1) ->
          let uu____245 = FStar_Extraction_ML_UEnv.lookup_ty_const g n1 in
          (match uu____245 with
           | FStar_Pervasives_Native.Some ts ->
               let uu____251 = try_subst ts args in
               (match uu____251 with
                | FStar_Pervasives_Native.None  ->
                    let uu____256 =
                      let uu____257 =
                        FStar_Extraction_ML_Syntax.string_of_mlpath n1 in
                      let uu____258 =
                        FStar_Util.string_of_int (FStar_List.length args) in
                      let uu____259 =
                        FStar_Util.string_of_int
                          (FStar_List.length (FStar_Pervasives_Native.fst ts)) in
                      FStar_Util.format3
                        "Substitution must be fully applied; got an application of %s with %s args whereas %s were expected (see GitHub issue #490)"
                        uu____257 uu____258 uu____259 in
                    failwith uu____256
                | FStar_Pervasives_Native.Some r ->
                    FStar_Pervasives_Native.Some r)
           | uu____263 -> FStar_Pervasives_Native.None)
      | uu____266 -> FStar_Pervasives_Native.None
let eff_leq:
  FStar_Extraction_ML_Syntax.e_tag ->
    FStar_Extraction_ML_Syntax.e_tag -> Prims.bool
  =
  fun f  ->
    fun f'  ->
      match (f, f') with
      | (FStar_Extraction_ML_Syntax.E_PURE ,uu____275) -> true
      | (FStar_Extraction_ML_Syntax.E_GHOST
         ,FStar_Extraction_ML_Syntax.E_GHOST ) -> true
      | (FStar_Extraction_ML_Syntax.E_IMPURE
         ,FStar_Extraction_ML_Syntax.E_IMPURE ) -> true
      | uu____276 -> false
let eff_to_string: FStar_Extraction_ML_Syntax.e_tag -> Prims.string =
  fun uu___148_284  ->
    match uu___148_284 with
    | FStar_Extraction_ML_Syntax.E_PURE  -> "Pure"
    | FStar_Extraction_ML_Syntax.E_GHOST  -> "Ghost"
    | FStar_Extraction_ML_Syntax.E_IMPURE  -> "Impure"
let join:
  FStar_Range.range ->
    FStar_Extraction_ML_Syntax.e_tag ->
      FStar_Extraction_ML_Syntax.e_tag -> FStar_Extraction_ML_Syntax.e_tag
  =
  fun r  ->
    fun f  ->
      fun f'  ->
        match (f, f') with
        | (FStar_Extraction_ML_Syntax.E_IMPURE
           ,FStar_Extraction_ML_Syntax.E_PURE ) ->
            FStar_Extraction_ML_Syntax.E_IMPURE
        | (FStar_Extraction_ML_Syntax.E_PURE
           ,FStar_Extraction_ML_Syntax.E_IMPURE ) ->
            FStar_Extraction_ML_Syntax.E_IMPURE
        | (FStar_Extraction_ML_Syntax.E_IMPURE
           ,FStar_Extraction_ML_Syntax.E_IMPURE ) ->
            FStar_Extraction_ML_Syntax.E_IMPURE
        | (FStar_Extraction_ML_Syntax.E_GHOST
           ,FStar_Extraction_ML_Syntax.E_GHOST ) ->
            FStar_Extraction_ML_Syntax.E_GHOST
        | (FStar_Extraction_ML_Syntax.E_PURE
           ,FStar_Extraction_ML_Syntax.E_GHOST ) ->
            FStar_Extraction_ML_Syntax.E_GHOST
        | (FStar_Extraction_ML_Syntax.E_GHOST
           ,FStar_Extraction_ML_Syntax.E_PURE ) ->
            FStar_Extraction_ML_Syntax.E_GHOST
        | (FStar_Extraction_ML_Syntax.E_PURE
           ,FStar_Extraction_ML_Syntax.E_PURE ) ->
            FStar_Extraction_ML_Syntax.E_PURE
        | uu____297 ->
            let uu____302 =
              let uu____303 = FStar_Range.string_of_range r in
              FStar_Util.format3
                "Impossible (%s): Inconsistent effects %s and %s" uu____303
                (eff_to_string f) (eff_to_string f') in
            failwith uu____302
let join_l:
  FStar_Range.range ->
    FStar_Extraction_ML_Syntax.e_tag Prims.list ->
      FStar_Extraction_ML_Syntax.e_tag
  =
  fun r  ->
    fun fs  ->
      FStar_List.fold_left (join r) FStar_Extraction_ML_Syntax.E_PURE fs
let mk_ty_fun:
  'Auu____322 .
    Prims.unit ->
      ('Auu____322,FStar_Extraction_ML_Syntax.mlty)
        FStar_Pervasives_Native.tuple2 Prims.list ->
        FStar_Extraction_ML_Syntax.mlty -> FStar_Extraction_ML_Syntax.mlty
  =
  fun uu____333  ->
    FStar_List.fold_right
      (fun uu____342  ->
         fun t  ->
           match uu____342 with
           | (uu____348,t0) ->
               FStar_Extraction_ML_Syntax.MLTY_Fun
                 (t0, FStar_Extraction_ML_Syntax.E_PURE, t))
type unfold_t =
  FStar_Extraction_ML_Syntax.mlty ->
    FStar_Extraction_ML_Syntax.mlty FStar_Pervasives_Native.option[@@deriving
                                                                    show]
let rec type_leq_c:
  unfold_t ->
    FStar_Extraction_ML_Syntax.mlexpr FStar_Pervasives_Native.option ->
      FStar_Extraction_ML_Syntax.mlty ->
        FStar_Extraction_ML_Syntax.mlty ->
          (Prims.bool,FStar_Extraction_ML_Syntax.mlexpr
                        FStar_Pervasives_Native.option)
            FStar_Pervasives_Native.tuple2
  =
  fun unfold_ty  ->
    fun e  ->
      fun t  ->
        fun t'  ->
          match (t, t') with
          | (FStar_Extraction_ML_Syntax.MLTY_Var
             x,FStar_Extraction_ML_Syntax.MLTY_Var y) ->
              if x = y
              then (true, e)
              else (false, FStar_Pervasives_Native.None)
          | (FStar_Extraction_ML_Syntax.MLTY_Fun
             (t1,f,t2),FStar_Extraction_ML_Syntax.MLTY_Fun (t1',f',t2')) ->
              let mk_fun xs body =
                match xs with
                | [] -> body
                | uu____435 ->
                    let e1 =
                      match body.FStar_Extraction_ML_Syntax.expr with
                      | FStar_Extraction_ML_Syntax.MLE_Fun (ys,body1) ->
                          FStar_Extraction_ML_Syntax.MLE_Fun
                            ((FStar_List.append xs ys), body1)
                      | uu____467 ->
                          FStar_Extraction_ML_Syntax.MLE_Fun (xs, body) in
                    let uu____474 =
                      (mk_ty_fun ()) xs body.FStar_Extraction_ML_Syntax.mlty in
                    FStar_Extraction_ML_Syntax.with_ty uu____474 e1 in
              (match e with
               | FStar_Pervasives_Native.Some
                   {
                     FStar_Extraction_ML_Syntax.expr =
                       FStar_Extraction_ML_Syntax.MLE_Fun (x::xs,body);
                     FStar_Extraction_ML_Syntax.mlty = uu____484;
                     FStar_Extraction_ML_Syntax.loc = uu____485;_}
                   ->
                   let uu____506 =
                     (type_leq unfold_ty t1' t1) && (eff_leq f f') in
                   if uu____506
                   then
                     (if
                        (f = FStar_Extraction_ML_Syntax.E_PURE) &&
                          (f' = FStar_Extraction_ML_Syntax.E_GHOST)
                      then
                        let uu____522 = type_leq unfold_ty t2 t2' in
                        (if uu____522
                         then
                           let body1 =
                             let uu____533 =
                               type_leq unfold_ty t2
                                 FStar_Extraction_ML_Syntax.ml_unit_ty in
                             if uu____533
                             then FStar_Extraction_ML_Syntax.ml_unit
                             else
                               FStar_All.pipe_left
                                 (FStar_Extraction_ML_Syntax.with_ty t2')
                                 (FStar_Extraction_ML_Syntax.MLE_Coerce
                                    (FStar_Extraction_ML_Syntax.ml_unit,
                                      FStar_Extraction_ML_Syntax.ml_unit_ty,
                                      t2')) in
                           let uu____538 =
                             let uu____541 =
                               let uu____542 =
                                 let uu____545 =
                                   (mk_ty_fun ()) [x]
                                     body1.FStar_Extraction_ML_Syntax.mlty in
                                 FStar_Extraction_ML_Syntax.with_ty uu____545 in
                               FStar_All.pipe_left uu____542
                                 (FStar_Extraction_ML_Syntax.MLE_Fun
                                    ([x], body1)) in
                             FStar_Pervasives_Native.Some uu____541 in
                           (true, uu____538)
                         else (false, FStar_Pervasives_Native.None))
                      else
                        (let uu____574 =
                           let uu____581 =
                             let uu____584 = mk_fun xs body in
                             FStar_All.pipe_left
                               (fun _0_42  ->
                                  FStar_Pervasives_Native.Some _0_42)
                               uu____584 in
                           type_leq_c unfold_ty uu____581 t2 t2' in
                         match uu____574 with
                         | (ok,body1) ->
                             let res =
                               match body1 with
                               | FStar_Pervasives_Native.Some body2 ->
                                   let uu____608 = mk_fun [x] body2 in
                                   FStar_Pervasives_Native.Some uu____608
                               | uu____617 -> FStar_Pervasives_Native.None in
                             (ok, res)))
                   else (false, FStar_Pervasives_Native.None)
               | uu____625 ->
                   let uu____628 =
                     ((type_leq unfold_ty t1' t1) && (eff_leq f f')) &&
                       (type_leq unfold_ty t2 t2') in
                   if uu____628
                   then (true, e)
                   else (false, FStar_Pervasives_Native.None))
          | (FStar_Extraction_ML_Syntax.MLTY_Named
             (args,path),FStar_Extraction_ML_Syntax.MLTY_Named (args',path'))
              ->
              if path = path'
              then
                let uu____664 =
                  FStar_List.forall2 (type_leq unfold_ty) args args' in
                (if uu____664
                 then (true, e)
                 else (false, FStar_Pervasives_Native.None))
              else
                (let uu____680 = unfold_ty t in
                 match uu____680 with
                 | FStar_Pervasives_Native.Some t1 ->
                     type_leq_c unfold_ty e t1 t'
                 | FStar_Pervasives_Native.None  ->
                     let uu____694 = unfold_ty t' in
                     (match uu____694 with
                      | FStar_Pervasives_Native.None  ->
                          (false, FStar_Pervasives_Native.None)
                      | FStar_Pervasives_Native.Some t'1 ->
                          type_leq_c unfold_ty e t t'1))
          | (FStar_Extraction_ML_Syntax.MLTY_Tuple
             ts,FStar_Extraction_ML_Syntax.MLTY_Tuple ts') ->
              let uu____716 = FStar_List.forall2 (type_leq unfold_ty) ts ts' in
              if uu____716
              then (true, e)
              else (false, FStar_Pervasives_Native.None)
          | (FStar_Extraction_ML_Syntax.MLTY_Top
             ,FStar_Extraction_ML_Syntax.MLTY_Top ) -> (true, e)
          | (FStar_Extraction_ML_Syntax.MLTY_Named uu____733,uu____734) ->
              let uu____741 = unfold_ty t in
              (match uu____741 with
               | FStar_Pervasives_Native.Some t1 ->
                   type_leq_c unfold_ty e t1 t'
               | uu____755 -> (false, FStar_Pervasives_Native.None))
          | (uu____760,FStar_Extraction_ML_Syntax.MLTY_Named uu____761) ->
              let uu____768 = unfold_ty t' in
              (match uu____768 with
               | FStar_Pervasives_Native.Some t'1 ->
                   type_leq_c unfold_ty e t t'1
               | uu____782 -> (false, FStar_Pervasives_Native.None))
          | uu____787 -> (false, FStar_Pervasives_Native.None)
and type_leq:
  unfold_t ->
    FStar_Extraction_ML_Syntax.mlty ->
      FStar_Extraction_ML_Syntax.mlty -> Prims.bool
  =
  fun g  ->
    fun t1  ->
      fun t2  ->
        let uu____798 = type_leq_c g FStar_Pervasives_Native.None t1 t2 in
        FStar_All.pipe_right uu____798 FStar_Pervasives_Native.fst
let is_type_abstraction:
  'Auu____824 'Auu____825 'Auu____826 .
    (('Auu____826,'Auu____825) FStar_Util.either,'Auu____824)
      FStar_Pervasives_Native.tuple2 Prims.list -> Prims.bool
  =
  fun uu___149_840  ->
    match uu___149_840 with
    | (FStar_Util.Inl uu____851,uu____852)::uu____853 -> true
    | uu____876 -> false
let is_xtuple:
  (Prims.string Prims.list,Prims.string) FStar_Pervasives_Native.tuple2 ->
    Prims.int FStar_Pervasives_Native.option
  =
  fun uu____898  ->
    match uu____898 with
    | (ns,n1) ->
        let uu____913 =
          let uu____914 = FStar_Util.concat_l "." (FStar_List.append ns [n1]) in
          FStar_Parser_Const.is_tuple_datacon_string uu____914 in
        if uu____913
        then
          let uu____917 =
            let uu____918 = FStar_Util.char_at n1 (Prims.parse_int "7") in
            FStar_Util.int_of_char uu____918 in
          FStar_Pervasives_Native.Some uu____917
        else FStar_Pervasives_Native.None
let resugar_exp:
  FStar_Extraction_ML_Syntax.mlexpr -> FStar_Extraction_ML_Syntax.mlexpr =
  fun e  ->
    match e.FStar_Extraction_ML_Syntax.expr with
    | FStar_Extraction_ML_Syntax.MLE_CTor (mlp,args) ->
        let uu____930 = is_xtuple mlp in
        (match uu____930 with
         | FStar_Pervasives_Native.Some n1 ->
             FStar_All.pipe_left
               (FStar_Extraction_ML_Syntax.with_ty
                  e.FStar_Extraction_ML_Syntax.mlty)
               (FStar_Extraction_ML_Syntax.MLE_Tuple args)
         | uu____934 -> e)
    | uu____937 -> e
let record_field_path:
  FStar_Ident.lident Prims.list -> Prims.string Prims.list =
  fun uu___150_945  ->
    match uu___150_945 with
    | f::uu____951 ->
        let uu____954 = FStar_Util.prefix f.FStar_Ident.ns in
        (match uu____954 with
         | (ns,uu____964) ->
             FStar_All.pipe_right ns
               (FStar_List.map (fun id  -> id.FStar_Ident.idText)))
    | uu____975 -> failwith "impos"
let record_fields:
  'Auu____986 .
    FStar_Ident.lident Prims.list ->
      'Auu____986 Prims.list ->
        (Prims.string,'Auu____986) FStar_Pervasives_Native.tuple2 Prims.list
  =
  fun fs  ->
    fun vs  ->
      FStar_List.map2
        (fun f  -> fun e  -> (((f.FStar_Ident.ident).FStar_Ident.idText), e))
        fs vs
let is_xtuple_ty:
  (Prims.string Prims.list,Prims.string) FStar_Pervasives_Native.tuple2 ->
    Prims.int FStar_Pervasives_Native.option
  =
  fun uu____1028  ->
    match uu____1028 with
    | (ns,n1) ->
        let uu____1043 =
          let uu____1044 =
            FStar_Util.concat_l "." (FStar_List.append ns [n1]) in
          FStar_Parser_Const.is_tuple_constructor_string uu____1044 in
        if uu____1043
        then
          let uu____1047 =
            let uu____1048 = FStar_Util.char_at n1 (Prims.parse_int "5") in
            FStar_Util.int_of_char uu____1048 in
          FStar_Pervasives_Native.Some uu____1047
        else FStar_Pervasives_Native.None
let resugar_mlty:
  FStar_Extraction_ML_Syntax.mlty -> FStar_Extraction_ML_Syntax.mlty =
  fun t  ->
    match t with
    | FStar_Extraction_ML_Syntax.MLTY_Named (args,mlp) ->
        let uu____1060 = is_xtuple_ty mlp in
        (match uu____1060 with
         | FStar_Pervasives_Native.Some n1 ->
             FStar_Extraction_ML_Syntax.MLTY_Tuple args
         | uu____1064 -> t)
    | uu____1067 -> t
let flatten_ns: Prims.string Prims.list -> Prims.string =
  fun ns  ->
    let uu____1076 = FStar_Options.codegen_fsharp () in
    if uu____1076
    then FStar_String.concat "." ns
    else FStar_String.concat "_" ns
let flatten_mlpath:
  (Prims.string Prims.list,Prims.string) FStar_Pervasives_Native.tuple2 ->
    Prims.string
  =
  fun uu____1087  ->
    match uu____1087 with
    | (ns,n1) ->
        let uu____1100 = FStar_Options.codegen_fsharp () in
        if uu____1100
        then FStar_String.concat "." (FStar_List.append ns [n1])
        else FStar_String.concat "_" (FStar_List.append ns [n1])
let mlpath_of_lid:
  FStar_Ident.lident ->
    (Prims.string Prims.list,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun l  ->
    let uu____1112 =
      FStar_All.pipe_right l.FStar_Ident.ns
        (FStar_List.map (fun i  -> i.FStar_Ident.idText)) in
    (uu____1112, ((l.FStar_Ident.ident).FStar_Ident.idText))
let rec erasableType:
  unfold_t -> FStar_Extraction_ML_Syntax.mlty -> Prims.bool =
  fun unfold_ty  ->
    fun t  ->
      if FStar_Extraction_ML_UEnv.erasableTypeNoDelta t
      then true
      else
        (let uu____1135 = unfold_ty t in
         match uu____1135 with
         | FStar_Pervasives_Native.Some t1 -> erasableType unfold_ty t1
         | FStar_Pervasives_Native.None  -> false)
let rec eraseTypeDeep:
  unfold_t ->
    FStar_Extraction_ML_Syntax.mlty -> FStar_Extraction_ML_Syntax.mlty
  =
  fun unfold_ty  ->
    fun t  ->
      match t with
      | FStar_Extraction_ML_Syntax.MLTY_Fun (tyd,etag,tycd) ->
          if etag = FStar_Extraction_ML_Syntax.E_PURE
          then
            let uu____1157 =
              let uu____1164 = eraseTypeDeep unfold_ty tyd in
              let uu____1168 = eraseTypeDeep unfold_ty tycd in
              (uu____1164, etag, uu____1168) in
            FStar_Extraction_ML_Syntax.MLTY_Fun uu____1157
          else t
      | FStar_Extraction_ML_Syntax.MLTY_Named (lty,mlp) ->
          let uu____1179 = erasableType unfold_ty t in
          if uu____1179
          then FStar_Extraction_ML_UEnv.erasedContent
          else
            (let uu____1184 =
               let uu____1191 = FStar_List.map (eraseTypeDeep unfold_ty) lty in
               (uu____1191, mlp) in
             FStar_Extraction_ML_Syntax.MLTY_Named uu____1184)
      | FStar_Extraction_ML_Syntax.MLTY_Tuple lty ->
          let uu____1202 = FStar_List.map (eraseTypeDeep unfold_ty) lty in
          FStar_Extraction_ML_Syntax.MLTY_Tuple uu____1202
      | uu____1208 -> t
let prims_op_equality: FStar_Extraction_ML_Syntax.mlexpr =
  FStar_All.pipe_left
    (FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.MLTY_Top)
    (FStar_Extraction_ML_Syntax.MLE_Name (["Prims"], "op_Equality"))
let prims_op_amp_amp: FStar_Extraction_ML_Syntax.mlexpr =
  let uu____1211 =
    let uu____1214 =
      (mk_ty_fun ())
        [("x", FStar_Extraction_ML_Syntax.ml_bool_ty);
        ("y", FStar_Extraction_ML_Syntax.ml_bool_ty)]
        FStar_Extraction_ML_Syntax.ml_bool_ty in
    FStar_Extraction_ML_Syntax.with_ty uu____1214 in
  FStar_All.pipe_left uu____1211
    (FStar_Extraction_ML_Syntax.MLE_Name (["Prims"], "op_AmpAmp"))
let conjoin:
  FStar_Extraction_ML_Syntax.mlexpr ->
    FStar_Extraction_ML_Syntax.mlexpr -> FStar_Extraction_ML_Syntax.mlexpr
  =
  fun e1  ->
    fun e2  ->
      FStar_All.pipe_left
        (FStar_Extraction_ML_Syntax.with_ty
           FStar_Extraction_ML_Syntax.ml_bool_ty)
        (FStar_Extraction_ML_Syntax.MLE_App (prims_op_amp_amp, [e1; e2]))
let conjoin_opt:
  FStar_Extraction_ML_Syntax.mlexpr FStar_Pervasives_Native.option ->
    FStar_Extraction_ML_Syntax.mlexpr FStar_Pervasives_Native.option ->
      FStar_Extraction_ML_Syntax.mlexpr FStar_Pervasives_Native.option
  =
  fun e1  ->
    fun e2  ->
      match (e1, e2) with
      | (FStar_Pervasives_Native.None ,FStar_Pervasives_Native.None ) ->
          FStar_Pervasives_Native.None
      | (FStar_Pervasives_Native.Some x,FStar_Pervasives_Native.None ) ->
          FStar_Pervasives_Native.Some x
      | (FStar_Pervasives_Native.None ,FStar_Pervasives_Native.Some x) ->
          FStar_Pervasives_Native.Some x
      | (FStar_Pervasives_Native.Some x,FStar_Pervasives_Native.Some y) ->
          let uu____1283 = conjoin x y in
          FStar_Pervasives_Native.Some uu____1283
let mlloc_of_range:
  FStar_Range.range ->
    (Prims.int,Prims.string) FStar_Pervasives_Native.tuple2
  =
  fun r  ->
    let pos = FStar_Range.start_of_range r in
    let line = FStar_Range.line_of_pos pos in
    let uu____1294 = FStar_Range.file_of_range r in (line, uu____1294)
let rec doms_and_cod:
  FStar_Extraction_ML_Syntax.mlty ->
    (FStar_Extraction_ML_Syntax.mlty Prims.list,FStar_Extraction_ML_Syntax.mlty)
      FStar_Pervasives_Native.tuple2
  =
  fun t  ->
    match t with
    | FStar_Extraction_ML_Syntax.MLTY_Fun (a,uu____1312,b) ->
        let uu____1314 = doms_and_cod b in
        (match uu____1314 with | (ds,c) -> ((a :: ds), c))
    | uu____1335 -> ([], t)
let argTypes:
  FStar_Extraction_ML_Syntax.mlty ->
    FStar_Extraction_ML_Syntax.mlty Prims.list
  =
  fun t  ->
    let uu____1346 = doms_and_cod t in FStar_Pervasives_Native.fst uu____1346
let rec uncurry_mlty_fun:
  FStar_Extraction_ML_Syntax.mlty ->
    (FStar_Extraction_ML_Syntax.mlty Prims.list,FStar_Extraction_ML_Syntax.mlty)
      FStar_Pervasives_Native.tuple2
  =
  fun t  ->
    match t with
    | FStar_Extraction_ML_Syntax.MLTY_Fun (a,uu____1372,b) ->
        let uu____1374 = uncurry_mlty_fun b in
        (match uu____1374 with | (args,res) -> ((a :: args), res))
    | uu____1395 -> ([], t)
exception CallNotImplemented
let uu___is_CallNotImplemented: Prims.exn -> Prims.bool =
  fun projectee  ->
    match projectee with | CallNotImplemented  -> true | uu____1402 -> false
let not_implemented_warning: Prims.string -> Prims.unit =
  fun t  ->
    let uu____1407 =
      FStar_Util.format1 ". Tactic %s will not run natively.\n" t in
    FStar_All.pipe_right uu____1407 FStar_Util.print_warning
type emb_decl =
  | Embed
  | Unembed[@@deriving show]
let uu___is_Embed: emb_decl -> Prims.bool =
  fun projectee  ->
    match projectee with | Embed  -> true | uu____1412 -> false
let uu___is_Unembed: emb_decl -> Prims.bool =
  fun projectee  ->
    match projectee with | Unembed  -> true | uu____1417 -> false
let lid_to_name: FStar_Ident.lident -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun l  ->
    let uu____1422 = FStar_Extraction_ML_Syntax.mlpath_of_lident l in
    FStar_Extraction_ML_Syntax.MLE_Name uu____1422
let lid_to_top_name: FStar_Ident.lident -> FStar_Extraction_ML_Syntax.mlexpr
  =
  fun l  ->
    let uu____1427 =
      let uu____1428 = FStar_Extraction_ML_Syntax.mlpath_of_lident l in
      FStar_Extraction_ML_Syntax.MLE_Name uu____1428 in
    FStar_All.pipe_left
      (FStar_Extraction_ML_Syntax.with_ty FStar_Extraction_ML_Syntax.MLTY_Top)
      uu____1427
let str_to_name: Prims.string -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun s  ->
    let uu____1433 = FStar_Ident.lid_of_str s in lid_to_name uu____1433
let str_to_top_name: Prims.string -> FStar_Extraction_ML_Syntax.mlexpr =
  fun s  ->
    let uu____1438 = FStar_Ident.lid_of_str s in lid_to_top_name uu____1438
let fstar_syn_syn_prefix: Prims.string -> FStar_Extraction_ML_Syntax.mlexpr'
  = fun s  -> str_to_name (Prims.strcat "FStar_Syntax_Syntax." s)
let fstar_tc_common_prefix:
  Prims.string -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun s  -> str_to_name (Prims.strcat "FStar_TypeChecker_Common." s)
let fstar_refl_basic_prefix:
  Prims.string -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun s  -> str_to_name (Prims.strcat "FStar_Reflection_Basic." s)
let fstar_refl_data_prefix:
  Prims.string -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun s  -> str_to_name (Prims.strcat "FStar_Reflection_Data." s)
let fstar_emb_basic_prefix:
  Prims.string -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun s  -> str_to_name (Prims.strcat "FStar_Syntax_Embeddings." s)
let mk_basic_embedding:
  emb_decl -> Prims.string -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun m  ->
    fun s  ->
      match m with
      | Embed  -> fstar_emb_basic_prefix (Prims.strcat "embed_" s)
      | Unembed  -> fstar_emb_basic_prefix (Prims.strcat "unembed_" s)
let mk_embedding:
  emb_decl -> Prims.string -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun m  ->
    fun s  ->
      match m with
      | Embed  -> fstar_refl_basic_prefix (Prims.strcat "embed_" s)
      | Unembed  -> fstar_refl_basic_prefix (Prims.strcat "unembed_" s)
let mk_tactic_unembedding:
  FStar_Extraction_ML_Syntax.mlexpr' Prims.list ->
    FStar_Extraction_ML_Syntax.mlexpr'
  =
  fun args  ->
    let tac_arg = "t" in
    let reify_tactic =
      let uu____1485 =
        let uu____1486 =
          let uu____1493 =
            str_to_top_name "FStar_Tactics_Interpreter.reify_tactic" in
          let uu____1494 =
            let uu____1497 = str_to_top_name tac_arg in [uu____1497] in
          (uu____1493, uu____1494) in
        FStar_Extraction_ML_Syntax.MLE_App uu____1486 in
      FStar_All.pipe_left
        (FStar_Extraction_ML_Syntax.with_ty
           FStar_Extraction_ML_Syntax.MLTY_Top) uu____1485 in
    let from_tac =
      let uu____1501 =
        let uu____1502 =
          FStar_Util.string_of_int
            ((FStar_List.length args) - (Prims.parse_int "1")) in
        Prims.strcat "FStar_Tactics_Builtins.from_tac_" uu____1502 in
      str_to_top_name uu____1501 in
    let unembed_tactic =
      let uu____1504 =
        let uu____1505 =
          FStar_Util.string_of_int
            ((FStar_List.length args) - (Prims.parse_int "1")) in
        Prims.strcat "FStar_Tactics_Interpreter.unembed_tactic_" uu____1505 in
      str_to_top_name uu____1504 in
    let app =
      match FStar_List.length args with
      | _0_43 when _0_43 = (Prims.parse_int "1") ->
          let uu____1507 =
            let uu____1514 =
              let uu____1517 =
                let uu____1518 =
                  let uu____1519 =
                    let uu____1526 =
                      let uu____1529 =
                        FStar_List.map
                          (FStar_Extraction_ML_Syntax.with_ty
                             FStar_Extraction_ML_Syntax.MLTY_Top) args in
                      FStar_List.append uu____1529 [reify_tactic] in
                    (unembed_tactic, uu____1526) in
                  FStar_Extraction_ML_Syntax.MLE_App uu____1519 in
                FStar_Extraction_ML_Syntax.with_ty
                  FStar_Extraction_ML_Syntax.MLTY_Top uu____1518 in
              [uu____1517] in
            (from_tac, uu____1514) in
          FStar_Extraction_ML_Syntax.MLE_App uu____1507
      | n1 ->
          ((let uu____1538 =
              let uu____1539 =
                let uu____1542 = FStar_Util.string_of_int n1 in [uu____1542] in
              FStar_Util.format
                "Unembedding not defined for tactics of %d arguments"
                uu____1539 in
            FStar_Util.print_warning uu____1538);
           FStar_Exn.raise CallNotImplemented) in
    FStar_Extraction_ML_Syntax.MLE_Fun
      ([(tac_arg, FStar_Extraction_ML_Syntax.MLTY_Top);
       ("()", FStar_Extraction_ML_Syntax.MLTY_Top)],
        (FStar_Extraction_ML_Syntax.with_ty
           FStar_Extraction_ML_Syntax.MLTY_Top app))
let rec mk_tac_param_type:
  FStar_Syntax_Syntax.term -> FStar_Extraction_ML_Syntax.mlexpr' =
  fun t  ->
    let uu____1571 =
      let uu____1572 = FStar_Syntax_Subst.compress t in
      uu____1572.FStar_Syntax_Syntax.n in
    match uu____1571 with
    | FStar_Syntax_Syntax.Tm_fvar fv when
        FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.int_lid ->
        fstar_syn_syn_prefix "t_int"
    | FStar_Syntax_Syntax.Tm_fvar fv when
        FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.bool_lid ->
        fstar_syn_syn_prefix "t_bool"
    | FStar_Syntax_Syntax.Tm_fvar fv when
        FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.unit_lid ->
        fstar_syn_syn_prefix "t_unit"
    | FStar_Syntax_Syntax.Tm_fvar fv when
        FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.string_lid ->
        fstar_syn_syn_prefix "t_string"
    | FStar_Syntax_Syntax.Tm_fvar fv when
        let uu____1580 = FStar_Reflection_Data.fstar_refl_types_lid "binder" in
        FStar_Syntax_Syntax.fv_eq_lid fv uu____1580 ->
        fstar_refl_data_prefix "t_binder"
    | FStar_Syntax_Syntax.Tm_fvar fv when
        let uu____1582 = FStar_Reflection_Data.fstar_refl_types_lid "term" in
        FStar_Syntax_Syntax.fv_eq_lid fv uu____1582 ->
        fstar_refl_data_prefix "t_term"
    | FStar_Syntax_Syntax.Tm_fvar fv when
        let uu____1584 = FStar_Reflection_Data.fstar_refl_types_lid "fv" in
        FStar_Syntax_Syntax.fv_eq_lid fv uu____1584 ->
        fstar_refl_data_prefix "t_fv"
    | FStar_Syntax_Syntax.Tm_fvar fv when
        let uu____1586 = FStar_Reflection_Data.fstar_refl_syntax_lid "binder" in
        FStar_Syntax_Syntax.fv_eq_lid fv uu____1586 ->
        fstar_refl_data_prefix "t_binders"
    | FStar_Syntax_Syntax.Tm_fvar fv when
        let uu____1588 =
          FStar_Reflection_Data.fstar_refl_syntax_lid "norm_step" in
        FStar_Syntax_Syntax.fv_eq_lid fv uu____1588 ->
        fstar_refl_data_prefix "t_norm_step"
    | FStar_Syntax_Syntax.Tm_app (h,args) ->
        let uu____1611 =
          let uu____1612 = FStar_Syntax_Subst.compress h in
          uu____1612.FStar_Syntax_Syntax.n in
        (match uu____1611 with
         | FStar_Syntax_Syntax.Tm_uinst (h',uu____1616) ->
             let uu____1621 =
               let uu____1622 = FStar_Syntax_Subst.compress h' in
               uu____1622.FStar_Syntax_Syntax.n in
             (match uu____1621 with
              | FStar_Syntax_Syntax.Tm_fvar fv when
                  FStar_Syntax_Syntax.fv_eq_lid fv
                    FStar_Parser_Const.list_lid
                  ->
                  let arg_term =
                    let uu____1629 = FStar_List.hd args in
                    FStar_Pervasives_Native.fst uu____1629 in
                  let uu____1644 =
                    let uu____1651 =
                      let uu____1652 = fstar_tc_common_prefix "t_list_of" in
                      FStar_Extraction_ML_Syntax.with_ty
                        FStar_Extraction_ML_Syntax.MLTY_Top uu____1652 in
                    let uu____1653 =
                      let uu____1656 =
                        let uu____1659 = mk_tac_param_type arg_term in
                        [uu____1659] in
                      FStar_List.map
                        (FStar_Extraction_ML_Syntax.with_ty
                           FStar_Extraction_ML_Syntax.MLTY_Top) uu____1656 in
                    (uu____1651, uu____1653) in
                  FStar_Extraction_ML_Syntax.MLE_App uu____1644
              | FStar_Syntax_Syntax.Tm_fvar fv when
                  FStar_Syntax_Syntax.fv_eq_lid fv
                    FStar_Parser_Const.option_lid
                  ->
                  let arg_term =
                    let uu____1666 = FStar_List.hd args in
                    FStar_Pervasives_Native.fst uu____1666 in
                  let uu____1681 =
                    let uu____1688 =
                      let uu____1689 = fstar_tc_common_prefix "t_option_of" in
                      FStar_Extraction_ML_Syntax.with_ty
                        FStar_Extraction_ML_Syntax.MLTY_Top uu____1689 in
                    let uu____1690 =
                      let uu____1693 =
                        let uu____1696 = mk_tac_param_type arg_term in
                        [uu____1696] in
                      FStar_List.map
                        (FStar_Extraction_ML_Syntax.with_ty
                           FStar_Extraction_ML_Syntax.MLTY_Top) uu____1693 in
                    (uu____1688, uu____1690) in
                  FStar_Extraction_ML_Syntax.MLE_App uu____1681
              | uu____1699 ->
                  ((let uu____1701 =
                      let uu____1702 =
                        let uu____1703 = FStar_Syntax_Subst.compress h' in
                        FStar_Syntax_Print.term_to_string uu____1703 in
                      Prims.strcat
                        "Type term not defined for higher-order type "
                        uu____1702 in
                    FStar_Util.print_warning uu____1701);
                   FStar_Exn.raise CallNotImplemented))
         | uu____1704 ->
             (FStar_Util.print_warning "Impossible";
              FStar_Exn.raise CallNotImplemented))
    | uu____1706 ->
        ((let uu____1708 =
            let uu____1709 =
              let uu____1710 = FStar_Syntax_Subst.compress t in
              FStar_Syntax_Print.term_to_string uu____1710 in
            Prims.strcat "Type term not defined for " uu____1709 in
          FStar_Util.print_warning uu____1708);
         FStar_Exn.raise CallNotImplemented)
let rec mk_tac_embedding_path:
  emb_decl -> FStar_Syntax_Syntax.term -> FStar_Extraction_ML_Syntax.mlexpr'
  =
  fun m  ->
    fun t  ->
      let uu____1719 =
        let uu____1720 = FStar_Syntax_Subst.compress t in
        uu____1720.FStar_Syntax_Syntax.n in
      match uu____1719 with
      | FStar_Syntax_Syntax.Tm_fvar fv when
          FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.int_lid ->
          mk_basic_embedding m "int"
      | FStar_Syntax_Syntax.Tm_fvar fv when
          FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.bool_lid ->
          mk_basic_embedding m "bool"
      | FStar_Syntax_Syntax.Tm_fvar fv when
          FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.unit_lid ->
          mk_basic_embedding m "unit"
      | FStar_Syntax_Syntax.Tm_fvar fv when
          FStar_Syntax_Syntax.fv_eq_lid fv FStar_Parser_Const.string_lid ->
          mk_basic_embedding m "string"
      | FStar_Syntax_Syntax.Tm_fvar fv when
          let uu____1728 =
            FStar_Reflection_Data.fstar_refl_types_lid "binder" in
          FStar_Syntax_Syntax.fv_eq_lid fv uu____1728 ->
          mk_embedding m "binder"
      | FStar_Syntax_Syntax.Tm_fvar fv when
          let uu____1730 = FStar_Reflection_Data.fstar_refl_types_lid "term" in
          FStar_Syntax_Syntax.fv_eq_lid fv uu____1730 ->
          mk_embedding m "term"
      | FStar_Syntax_Syntax.Tm_fvar fv when
          let uu____1732 = FStar_Reflection_Data.fstar_refl_types_lid "fv" in
          FStar_Syntax_Syntax.fv_eq_lid fv uu____1732 ->
          mk_embedding m "fvar"
      | FStar_Syntax_Syntax.Tm_fvar fv when
          let uu____1734 =
            FStar_Reflection_Data.fstar_refl_syntax_lid "binders" in
          FStar_Syntax_Syntax.fv_eq_lid fv uu____1734 ->
          mk_embedding m "binders"
      | FStar_Syntax_Syntax.Tm_fvar fv when
          let uu____1736 =
            FStar_Reflection_Data.fstar_refl_syntax_lid "norm_step" in
          FStar_Syntax_Syntax.fv_eq_lid fv uu____1736 ->
          mk_embedding m "norm_step"
      | FStar_Syntax_Syntax.Tm_app (h,args) ->
          let uu____1759 =
            let uu____1760 = FStar_Syntax_Subst.compress h in
            uu____1760.FStar_Syntax_Syntax.n in
          (match uu____1759 with
           | FStar_Syntax_Syntax.Tm_uinst (h',uu____1764) ->
               let uu____1769 =
                 let uu____1780 =
                   let uu____1781 = FStar_Syntax_Subst.compress h' in
                   uu____1781.FStar_Syntax_Syntax.n in
                 match uu____1780 with
                 | FStar_Syntax_Syntax.Tm_fvar fv when
                     FStar_Syntax_Syntax.fv_eq_lid fv
                       FStar_Parser_Const.list_lid
                     ->
                     let arg_term =
                       let uu____1798 = FStar_List.hd args in
                       FStar_Pervasives_Native.fst uu____1798 in
                     let uu____1813 =
                       let uu____1816 = mk_tac_embedding_path m arg_term in
                       [uu____1816] in
                     let uu____1817 = mk_tac_param_type arg_term in
                     ("list", uu____1813, uu____1817, false)
                 | FStar_Syntax_Syntax.Tm_fvar fv when
                     FStar_Syntax_Syntax.fv_eq_lid fv
                       FStar_Parser_Const.option_lid
                     ->
                     let arg_term =
                       let uu____1824 = FStar_List.hd args in
                       FStar_Pervasives_Native.fst uu____1824 in
                     let uu____1839 =
                       let uu____1842 = mk_tac_embedding_path m arg_term in
                       [uu____1842] in
                     let uu____1843 = mk_tac_param_type arg_term in
                     ("option", uu____1839, uu____1843, false)
                 | FStar_Syntax_Syntax.Tm_fvar fv when
                     FStar_Syntax_Syntax.fv_eq_lid fv
                       FStar_Parser_Const.tactic_lid
                     ->
                     let arg_term =
                       let uu____1850 = FStar_List.hd args in
                       FStar_Pervasives_Native.fst uu____1850 in
                     let uu____1865 =
                       let uu____1868 = mk_tac_embedding_path m arg_term in
                       [uu____1868] in
                     let uu____1869 = mk_tac_param_type arg_term in
                     ("list", uu____1865, uu____1869, true)
                 | uu____1872 ->
                     ((let uu____1874 =
                         let uu____1875 =
                           let uu____1876 = FStar_Syntax_Subst.compress h' in
                           FStar_Syntax_Print.term_to_string uu____1876 in
                         Prims.strcat
                           "Embedding not defined for higher-order type "
                           uu____1875 in
                       FStar_Util.print_warning uu____1874);
                      FStar_Exn.raise CallNotImplemented) in
               (match uu____1769 with
                | (ht,hargs,type_arg,is_tactic) ->
                    let hargs1 =
                      match m with
                      | Embed  -> FStar_List.append hargs [type_arg]
                      | Unembed  -> hargs in
                    if is_tactic
                    then
                      (match m with
                       | Embed  ->
                           (FStar_Util.print_warning
                              "Embedding not defined for tactic type";
                            FStar_Exn.raise CallNotImplemented)
                       | Unembed  -> mk_tactic_unembedding hargs1)
                    else
                      (let uu____1902 =
                         let uu____1909 =
                           let uu____1910 = mk_basic_embedding m ht in
                           FStar_Extraction_ML_Syntax.with_ty
                             FStar_Extraction_ML_Syntax.MLTY_Top uu____1910 in
                         let uu____1911 =
                           FStar_List.map
                             (FStar_Extraction_ML_Syntax.with_ty
                                FStar_Extraction_ML_Syntax.MLTY_Top) hargs1 in
                         (uu____1909, uu____1911) in
                       FStar_Extraction_ML_Syntax.MLE_App uu____1902))
           | uu____1916 ->
               (FStar_Util.print_warning "Impossible";
                FStar_Exn.raise CallNotImplemented))
      | uu____1918 ->
          ((let uu____1920 =
              let uu____1921 =
                let uu____1922 = FStar_Syntax_Subst.compress t in
                FStar_Syntax_Print.term_to_string uu____1922 in
              Prims.strcat "Embedding not defined for type " uu____1921 in
            FStar_Util.print_warning uu____1920);
           FStar_Exn.raise CallNotImplemented)
let mk_interpretation_fun:
  'Auu____1933 .
    FStar_Ident.lident ->
      FStar_Extraction_ML_Syntax.mlexpr' ->
        FStar_Syntax_Syntax.term ->
          (FStar_Syntax_Syntax.bv,'Auu____1933)
            FStar_Pervasives_Native.tuple2 Prims.list ->
            FStar_Extraction_ML_Syntax.mlexpr' FStar_Pervasives_Native.option
  =
  fun tac_lid  ->
    fun assm_lid  ->
      fun t  ->
        fun bs  ->
          try
            let arg_types =
              FStar_List.map
                (fun x  ->
                   (FStar_Pervasives_Native.fst x).FStar_Syntax_Syntax.sort)
                bs in
            let arity = FStar_List.length bs in
            let h =
              let uu____2000 =
                let uu____2001 = FStar_Util.string_of_int arity in
                Prims.strcat
                  "FStar_Tactics_Interpreter.mk_tactic_interpretation_"
                  uu____2001 in
              str_to_top_name uu____2000 in
            let tac_fun =
              let uu____2009 =
                let uu____2016 =
                  let uu____2017 =
                    let uu____2018 = FStar_Util.string_of_int arity in
                    Prims.strcat "FStar_Tactics_Native.from_tactic_"
                      uu____2018 in
                  str_to_top_name uu____2017 in
                let uu____2025 =
                  let uu____2028 = lid_to_top_name tac_lid in [uu____2028] in
                (uu____2016, uu____2025) in
              FStar_Extraction_ML_Syntax.MLE_App uu____2009 in
            let tac_lid_app =
              let uu____2032 =
                let uu____2039 = str_to_top_name "FStar_Ident.lid_of_str" in
                (uu____2039,
                  [FStar_Extraction_ML_Syntax.with_ty
                     FStar_Extraction_ML_Syntax.MLTY_Top assm_lid]) in
              FStar_Extraction_ML_Syntax.MLE_App uu____2032 in
            let args =
              let uu____2045 =
                let uu____2048 =
                  FStar_List.map (mk_tac_embedding_path Unembed) arg_types in
                let uu____2051 =
                  let uu____2054 = mk_tac_embedding_path Embed t in
                  let uu____2055 =
                    let uu____2058 = mk_tac_param_type t in
                    let uu____2059 =
                      let uu____2062 =
                        let uu____2065 = str_to_name "args" in [uu____2065] in
                      tac_lid_app :: uu____2062 in
                    uu____2058 :: uu____2059 in
                  uu____2054 :: uu____2055 in
                FStar_List.append uu____2048 uu____2051 in
              FStar_List.append [tac_fun] uu____2045 in
            let app =
              let uu____2067 =
                let uu____2068 =
                  let uu____2075 =
                    FStar_List.map
                      (FStar_Extraction_ML_Syntax.with_ty
                         FStar_Extraction_ML_Syntax.MLTY_Top) args in
                  (h, uu____2075) in
                FStar_Extraction_ML_Syntax.MLE_App uu____2068 in
              FStar_All.pipe_left
                (FStar_Extraction_ML_Syntax.with_ty
                   FStar_Extraction_ML_Syntax.MLTY_Top) uu____2067 in
            FStar_Pervasives_Native.Some
              (FStar_Extraction_ML_Syntax.MLE_Fun
                 ([("args", FStar_Extraction_ML_Syntax.MLTY_Top)], app))
          with
          | CallNotImplemented  ->
              ((let uu____2100 = FStar_Ident.string_of_lid tac_lid in
                not_implemented_warning uu____2100);
               FStar_Pervasives_Native.None)