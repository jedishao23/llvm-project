; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -slp-vectorizer -slp-threshold=-999 -S -mtriple=x86_64-unknown-linux-gnu -mcpu=skylake < %s | FileCheck %s

declare i64 @may_inf_loop_ro() nounwind readonly
declare i64 @may_inf_loop_rw() nounwind
declare i64 @may_throw() willreturn

; Base case with no interesting control dependencies
define void @test_no_control(i64* %a, i64* %b, i64* %c) {
; CHECK-LABEL: @test_no_control(
; CHECK-NEXT:    [[A2:%.*]] = getelementptr i64, i64* [[A:%.*]], i32 1
; CHECK-NEXT:    [[CA2:%.*]] = getelementptr i64, i64* [[C:%.*]], i32 1
; CHECK-NEXT:    [[B2:%.*]] = getelementptr i64, i64* [[B:%.*]], i32 1
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i64* [[A]] to <2 x i64>*
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x i64>, <2 x i64>* [[TMP1]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i64* [[C]] to <2 x i64>*
; CHECK-NEXT:    [[TMP4:%.*]] = load <2 x i64>, <2 x i64>* [[TMP3]], align 4
; CHECK-NEXT:    [[TMP5:%.*]] = add <2 x i64> [[TMP2]], [[TMP4]]
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast i64* [[B]] to <2 x i64>*
; CHECK-NEXT:    store <2 x i64> [[TMP5]], <2 x i64>* [[TMP6]], align 4
; CHECK-NEXT:    ret void
;
  %v1 = load i64, i64* %a
  %a2 = getelementptr i64, i64* %a, i32 1
  %v2 = load i64, i64* %a2

  %c1 = load i64, i64* %c
  %ca2 = getelementptr i64, i64* %c, i32 1
  %c2 = load i64, i64* %ca2
  %add1 = add i64 %v1, %c1
  %add2 = add i64 %v2, %c2

  store i64 %add1, i64* %b
  %b2 = getelementptr i64, i64* %b, i32 1
  store i64 %add2, i64* %b2
  ret void
}

define void @test1(i64* %a, i64* %b, i64* %c) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[A2:%.*]] = getelementptr i64, i64* [[A:%.*]], i32 1
; CHECK-NEXT:    [[C1:%.*]] = load i64, i64* [[C:%.*]], align 4
; CHECK-NEXT:    [[C2:%.*]] = call i64 @may_inf_loop_ro()
; CHECK-NEXT:    [[B2:%.*]] = getelementptr i64, i64* [[B:%.*]], i32 1
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i64* [[A]] to <2 x i64>*
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x i64>, <2 x i64>* [[TMP1]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <2 x i64> poison, i64 [[C1]], i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x i64> [[TMP3]], i64 [[C2]], i32 1
; CHECK-NEXT:    [[TMP5:%.*]] = add <2 x i64> [[TMP2]], [[TMP4]]
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast i64* [[B]] to <2 x i64>*
; CHECK-NEXT:    store <2 x i64> [[TMP5]], <2 x i64>* [[TMP6]], align 4
; CHECK-NEXT:    ret void
;
  %v1 = load i64, i64* %a
  %a2 = getelementptr i64, i64* %a, i32 1
  %v2 = load i64, i64* %a2

  %c1 = load i64, i64* %c
  %c2 = call i64 @may_inf_loop_ro()
  %add1 = add i64 %v1, %c1
  %add2 = add i64 %v2, %c2

  store i64 %add1, i64* %b
  %b2 = getelementptr i64, i64* %b, i32 1
  store i64 %add2, i64* %b2
  ret void
}

define void @test2(i64* %a, i64* %b, i64* %c) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[C1:%.*]] = load i64, i64* [[C:%.*]], align 4
; CHECK-NEXT:    [[C2:%.*]] = call i64 @may_inf_loop_ro()
; CHECK-NEXT:    [[A2:%.*]] = getelementptr i64, i64* [[A:%.*]], i32 1
; CHECK-NEXT:    [[B2:%.*]] = getelementptr i64, i64* [[B:%.*]], i32 1
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i64* [[A]] to <2 x i64>*
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x i64>, <2 x i64>* [[TMP1]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <2 x i64> poison, i64 [[C1]], i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x i64> [[TMP3]], i64 [[C2]], i32 1
; CHECK-NEXT:    [[TMP5:%.*]] = add <2 x i64> [[TMP2]], [[TMP4]]
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast i64* [[B]] to <2 x i64>*
; CHECK-NEXT:    store <2 x i64> [[TMP5]], <2 x i64>* [[TMP6]], align 4
; CHECK-NEXT:    ret void
;
  %c1 = load i64, i64* %c
  %c2 = call i64 @may_inf_loop_ro()

  %v1 = load i64, i64* %a
  %a2 = getelementptr i64, i64* %a, i32 1
  %v2 = load i64, i64* %a2

  %add1 = add i64 %v1, %c1
  %add2 = add i64 %v2, %c2

  store i64 %add1, i64* %b
  %b2 = getelementptr i64, i64* %b, i32 1
  store i64 %add2, i64* %b2
  ret void
}

define void @test3(i64* %a, i64* %b, i64* %c) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[C1:%.*]] = load i64, i64* [[C:%.*]], align 4
; CHECK-NEXT:    [[A2:%.*]] = getelementptr i64, i64* [[A:%.*]], i32 1
; CHECK-NEXT:    [[C2:%.*]] = call i64 @may_inf_loop_ro()
; CHECK-NEXT:    [[B2:%.*]] = getelementptr i64, i64* [[B:%.*]], i32 1
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i64* [[A]] to <2 x i64>*
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x i64>, <2 x i64>* [[TMP1]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <2 x i64> poison, i64 [[C1]], i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x i64> [[TMP3]], i64 [[C2]], i32 1
; CHECK-NEXT:    [[TMP5:%.*]] = add <2 x i64> [[TMP2]], [[TMP4]]
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast i64* [[B]] to <2 x i64>*
; CHECK-NEXT:    store <2 x i64> [[TMP5]], <2 x i64>* [[TMP6]], align 4
; CHECK-NEXT:    ret void
;
  %v1 = load i64, i64* %a
  %c1 = load i64, i64* %c
  %add1 = add i64 %v1, %c1

  %a2 = getelementptr i64, i64* %a, i32 1
  %v2 = load i64, i64* %a2
  %c2 = call i64 @may_inf_loop_ro()
  %add2 = add i64 %v2, %c2

  store i64 %add1, i64* %b
  %b2 = getelementptr i64, i64* %b, i32 1
  store i64 %add2, i64* %b2
  ret void
}

define void @test4(i64* %a, i64* %b, i64* %c) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    [[C1:%.*]] = load i64, i64* [[C:%.*]], align 4
; CHECK-NEXT:    [[C2:%.*]] = call i64 @may_inf_loop_ro()
; CHECK-NEXT:    [[A2:%.*]] = getelementptr i64, i64* [[A:%.*]], i32 1
; CHECK-NEXT:    [[B2:%.*]] = getelementptr i64, i64* [[B:%.*]], i32 1
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i64* [[A]] to <2 x i64>*
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x i64>, <2 x i64>* [[TMP1]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <2 x i64> poison, i64 [[C1]], i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x i64> [[TMP3]], i64 [[C2]], i32 1
; CHECK-NEXT:    [[TMP5:%.*]] = add <2 x i64> [[TMP2]], [[TMP4]]
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast i64* [[B]] to <2 x i64>*
; CHECK-NEXT:    store <2 x i64> [[TMP5]], <2 x i64>* [[TMP6]], align 4
; CHECK-NEXT:    ret void
;
  %v1 = load i64, i64* %a
  %c1 = load i64, i64* %c
  %add1 = add i64 %v1, %c1

  %c2 = call i64 @may_inf_loop_ro()
  %a2 = getelementptr i64, i64* %a, i32 1
  %v2 = load i64, i64* %a2
  %add2 = add i64 %v2, %c2

  store i64 %add1, i64* %b
  %b2 = getelementptr i64, i64* %b, i32 1
  store i64 %add2, i64* %b2
  ret void
}

define void @test5(i64* %a, i64* %b, i64* %c) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    [[A2:%.*]] = getelementptr i64, i64* [[A:%.*]], i32 1
; CHECK-NEXT:    [[C2:%.*]] = call i64 @may_inf_loop_ro()
; CHECK-NEXT:    [[C1:%.*]] = load i64, i64* [[C:%.*]], align 4
; CHECK-NEXT:    [[B2:%.*]] = getelementptr i64, i64* [[B:%.*]], i32 1
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i64* [[A]] to <2 x i64>*
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x i64>, <2 x i64>* [[TMP1]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <2 x i64> poison, i64 [[C1]], i32 0
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x i64> [[TMP3]], i64 [[C2]], i32 1
; CHECK-NEXT:    [[TMP5:%.*]] = add <2 x i64> [[TMP2]], [[TMP4]]
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast i64* [[B]] to <2 x i64>*
; CHECK-NEXT:    store <2 x i64> [[TMP5]], <2 x i64>* [[TMP6]], align 4
; CHECK-NEXT:    ret void
;
  %a2 = getelementptr i64, i64* %a, i32 1
  %v2 = load i64, i64* %a2
  %c2 = call i64 @may_inf_loop_ro()
  %add2 = add i64 %v2, %c2

  %v1 = load i64, i64* %a
  %c1 = load i64, i64* %c
  %add1 = add i64 %v1, %c1

  store i64 %add1, i64* %b
  %b2 = getelementptr i64, i64* %b, i32 1
  store i64 %add2, i64* %b2
  ret void
}

define void @test6(i64* %a, i64* %b, i64* %c) {
; CHECK-LABEL: @test6(
; CHECK-NEXT:    [[TMP1:%.*]] = call i64 @may_inf_loop_ro()
; CHECK-NEXT:    [[A2:%.*]] = getelementptr i64, i64* [[A:%.*]], i32 1
; CHECK-NEXT:    [[CA2:%.*]] = getelementptr i64, i64* [[C:%.*]], i32 1
; CHECK-NEXT:    [[B2:%.*]] = getelementptr i64, i64* [[B:%.*]], i32 1
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i64* [[A]] to <2 x i64>*
; CHECK-NEXT:    [[TMP3:%.*]] = load <2 x i64>, <2 x i64>* [[TMP2]], align 4
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast i64* [[C]] to <2 x i64>*
; CHECK-NEXT:    [[TMP5:%.*]] = load <2 x i64>, <2 x i64>* [[TMP4]], align 4
; CHECK-NEXT:    [[TMP6:%.*]] = add <2 x i64> [[TMP3]], [[TMP5]]
; CHECK-NEXT:    [[TMP7:%.*]] = bitcast i64* [[B]] to <2 x i64>*
; CHECK-NEXT:    store <2 x i64> [[TMP6]], <2 x i64>* [[TMP7]], align 4
; CHECK-NEXT:    ret void
;
  %v1 = load i64, i64* %a
  call i64 @may_inf_loop_ro()
  %a2 = getelementptr i64, i64* %a, i32 1
  %v2 = load i64, i64* %a2

  %c1 = load i64, i64* %c
  %ca2 = getelementptr i64, i64* %c, i32 1
  %c2 = load i64, i64* %ca2
  %add1 = add i64 %v1, %c1
  %add2 = add i64 %v2, %c2

  store i64 %add1, i64* %b
  %b2 = getelementptr i64, i64* %b, i32 1
  store i64 %add2, i64* %b2
  ret void
}

; In this case, we can't vectorize the load pair because there's no valid
; scheduling point which respects both memory and control dependence.  If
; we scheduled the second load before the store holding the first one in place,
; we'd have hoisted a potentially faulting load above a potentially infinite
; call and thus have introduced a possible fault into a program which didn't
; previously exist.
define void @test7(i64* %a, i64* %b, i64* %c) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    [[A2:%.*]] = getelementptr i64, i64* [[A:%.*]], i32 1
; CHECK-NEXT:    [[CA2:%.*]] = getelementptr i64, i64* [[C:%.*]], i32 1
; CHECK-NEXT:    [[B2:%.*]] = getelementptr i64, i64* [[B:%.*]], i32 1
; CHECK-NEXT:    [[V1:%.*]] = load i64, i64* [[A]], align 4
; CHECK-NEXT:    store i64 0, i64* [[A]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = call i64 @may_inf_loop_ro()
; CHECK-NEXT:    [[V2:%.*]] = load i64, i64* [[A2]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i64* [[C]] to <2 x i64>*
; CHECK-NEXT:    [[TMP3:%.*]] = load <2 x i64>, <2 x i64>* [[TMP2]], align 4
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x i64> poison, i64 [[V1]], i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = insertelement <2 x i64> [[TMP4]], i64 [[V2]], i32 1
; CHECK-NEXT:    [[TMP6:%.*]] = add <2 x i64> [[TMP5]], [[TMP3]]
; CHECK-NEXT:    [[TMP7:%.*]] = bitcast i64* [[B]] to <2 x i64>*
; CHECK-NEXT:    store <2 x i64> [[TMP6]], <2 x i64>* [[TMP7]], align 4
; CHECK-NEXT:    ret void
;
  %v1 = load i64, i64* %a
  store i64 0, i64* %a
  call i64 @may_inf_loop_ro()
  %a2 = getelementptr i64, i64* %a, i32 1
  %v2 = load i64, i64* %a2

  %c1 = load i64, i64* %c
  %ca2 = getelementptr i64, i64* %c, i32 1
  %c2 = load i64, i64* %ca2
  %add1 = add i64 %v1, %c1
  %add2 = add i64 %v2, %c2

  store i64 %add1, i64* %b
  %b2 = getelementptr i64, i64* %b, i32 1
  store i64 %add2, i64* %b2
  ret void
}

; Same as test7, but with a throwing call
define void @test8(i64* %a, i64* %b, i64* %c) {
; CHECK-LABEL: @test8(
; CHECK-NEXT:    [[A2:%.*]] = getelementptr i64, i64* [[A:%.*]], i32 1
; CHECK-NEXT:    [[CA2:%.*]] = getelementptr i64, i64* [[C:%.*]], i32 1
; CHECK-NEXT:    [[B2:%.*]] = getelementptr i64, i64* [[B:%.*]], i32 1
; CHECK-NEXT:    [[V1:%.*]] = load i64, i64* [[A]], align 4
; CHECK-NEXT:    store i64 0, i64* [[A]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = call i64 @may_throw() #[[ATTR4:[0-9]+]]
; CHECK-NEXT:    [[V2:%.*]] = load i64, i64* [[A2]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i64* [[C]] to <2 x i64>*
; CHECK-NEXT:    [[TMP3:%.*]] = load <2 x i64>, <2 x i64>* [[TMP2]], align 4
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x i64> poison, i64 [[V1]], i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = insertelement <2 x i64> [[TMP4]], i64 [[V2]], i32 1
; CHECK-NEXT:    [[TMP6:%.*]] = add <2 x i64> [[TMP5]], [[TMP3]]
; CHECK-NEXT:    [[TMP7:%.*]] = bitcast i64* [[B]] to <2 x i64>*
; CHECK-NEXT:    store <2 x i64> [[TMP6]], <2 x i64>* [[TMP7]], align 4
; CHECK-NEXT:    ret void
;
  %v1 = load i64, i64* %a
  store i64 0, i64* %a
  call i64 @may_throw() readonly
  %a2 = getelementptr i64, i64* %a, i32 1
  %v2 = load i64, i64* %a2

  %c1 = load i64, i64* %c
  %ca2 = getelementptr i64, i64* %c, i32 1
  %c2 = load i64, i64* %ca2
  %add1 = add i64 %v1, %c1
  %add2 = add i64 %v2, %c2

  store i64 %add1, i64* %b
  %b2 = getelementptr i64, i64* %b, i32 1
  store i64 %add2, i64* %b2
  ret void
}

; Same as test8, but with a readwrite maythrow call
define void @test9(i64* %a, i64* %b, i64* %c) {
; CHECK-LABEL: @test9(
; CHECK-NEXT:    [[A2:%.*]] = getelementptr i64, i64* [[A:%.*]], i32 1
; CHECK-NEXT:    [[CA2:%.*]] = getelementptr i64, i64* [[C:%.*]], i32 1
; CHECK-NEXT:    [[B2:%.*]] = getelementptr i64, i64* [[B:%.*]], i32 1
; CHECK-NEXT:    [[V1:%.*]] = load i64, i64* [[A]], align 4
; CHECK-NEXT:    store i64 0, i64* [[A]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = call i64 @may_throw()
; CHECK-NEXT:    [[V2:%.*]] = load i64, i64* [[A2]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i64* [[C]] to <2 x i64>*
; CHECK-NEXT:    [[TMP3:%.*]] = load <2 x i64>, <2 x i64>* [[TMP2]], align 4
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x i64> poison, i64 [[V1]], i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = insertelement <2 x i64> [[TMP4]], i64 [[V2]], i32 1
; CHECK-NEXT:    [[TMP6:%.*]] = add <2 x i64> [[TMP5]], [[TMP3]]
; CHECK-NEXT:    [[TMP7:%.*]] = bitcast i64* [[B]] to <2 x i64>*
; CHECK-NEXT:    store <2 x i64> [[TMP6]], <2 x i64>* [[TMP7]], align 4
; CHECK-NEXT:    ret void
;
  %v1 = load i64, i64* %a
  store i64 0, i64* %a
  call i64 @may_throw()
  %a2 = getelementptr i64, i64* %a, i32 1
  %v2 = load i64, i64* %a2

  %c1 = load i64, i64* %c
  %ca2 = getelementptr i64, i64* %c, i32 1
  %c2 = load i64, i64* %ca2
  %add1 = add i64 %v1, %c1
  %add2 = add i64 %v2, %c2

  store i64 %add1, i64* %b
  %b2 = getelementptr i64, i64* %b, i32 1
  store i64 %add2, i64* %b2
  ret void
}

; A variant of test7 which shows the same problem with a non-load instruction
define void @test10(i64* %a, i64* %b, i64* %c) {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    [[V1:%.*]] = load i64, i64* [[A:%.*]], align 4
; CHECK-NEXT:    [[A2:%.*]] = getelementptr i64, i64* [[A]], i32 1
; CHECK-NEXT:    [[V2:%.*]] = load i64, i64* [[A2]], align 4
; CHECK-NEXT:    [[CA2:%.*]] = getelementptr i64, i64* [[C:%.*]], i32 1
; CHECK-NEXT:    [[B2:%.*]] = getelementptr i64, i64* [[B:%.*]], i32 1
; CHECK-NEXT:    [[U1:%.*]] = udiv i64 200, [[V1]]
; CHECK-NEXT:    store i64 [[U1]], i64* [[A]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = call i64 @may_inf_loop_ro()
; CHECK-NEXT:    [[U2:%.*]] = udiv i64 200, [[V2]]
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i64* [[C]] to <2 x i64>*
; CHECK-NEXT:    [[TMP3:%.*]] = load <2 x i64>, <2 x i64>* [[TMP2]], align 4
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x i64> poison, i64 [[U1]], i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = insertelement <2 x i64> [[TMP4]], i64 [[U2]], i32 1
; CHECK-NEXT:    [[TMP6:%.*]] = add <2 x i64> [[TMP5]], [[TMP3]]
; CHECK-NEXT:    [[TMP7:%.*]] = bitcast i64* [[B]] to <2 x i64>*
; CHECK-NEXT:    store <2 x i64> [[TMP6]], <2 x i64>* [[TMP7]], align 4
; CHECK-NEXT:    ret void
;
  %v1 = load i64, i64* %a
  %a2 = getelementptr i64, i64* %a, i32 1
  %v2 = load i64, i64* %a2

  %u1 = udiv i64 200, %v1
  store i64 %u1, i64* %a
  call i64 @may_inf_loop_ro()
  %u2 = udiv i64 200, %v2

  %c1 = load i64, i64* %c
  %ca2 = getelementptr i64, i64* %c, i32 1
  %c2 = load i64, i64* %ca2
  %add1 = add i64 %u1, %c1
  %add2 = add i64 %u2, %c2

  store i64 %add1, i64* %b
  %b2 = getelementptr i64, i64* %b, i32 1
  store i64 %add2, i64* %b2
  ret void
}

; Variant of test10 block invariant operands to the udivs
; FIXME: This is wrong, we're hoisting a faulting udiv above an infinite loop.
define void @test11(i64 %x, i64 %y, i64* %b, i64* %c) {
; CHECK-LABEL: @test11(
; CHECK-NEXT:    [[CA2:%.*]] = getelementptr i64, i64* [[C:%.*]], i32 1
; CHECK-NEXT:    [[B2:%.*]] = getelementptr i64, i64* [[B:%.*]], i32 1
; CHECK-NEXT:    [[U1:%.*]] = udiv i64 200, [[X:%.*]]
; CHECK-NEXT:    store i64 [[U1]], i64* [[B]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = call i64 @may_inf_loop_ro()
; CHECK-NEXT:    [[U2:%.*]] = udiv i64 200, [[Y:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i64* [[C]] to <2 x i64>*
; CHECK-NEXT:    [[TMP3:%.*]] = load <2 x i64>, <2 x i64>* [[TMP2]], align 4
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <2 x i64> poison, i64 [[U1]], i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = insertelement <2 x i64> [[TMP4]], i64 [[U2]], i32 1
; CHECK-NEXT:    [[TMP6:%.*]] = add <2 x i64> [[TMP5]], [[TMP3]]
; CHECK-NEXT:    [[TMP7:%.*]] = bitcast i64* [[B]] to <2 x i64>*
; CHECK-NEXT:    store <2 x i64> [[TMP6]], <2 x i64>* [[TMP7]], align 4
; CHECK-NEXT:    ret void
;
  %u1 = udiv i64 200, %x
  store i64 %u1, i64* %b
  call i64 @may_inf_loop_ro()
  %u2 = udiv i64 200, %y

  %c1 = load i64, i64* %c
  %ca2 = getelementptr i64, i64* %c, i32 1
  %c2 = load i64, i64* %ca2
  %add1 = add i64 %u1, %c1
  %add2 = add i64 %u2, %c2

  store i64 %add1, i64* %b
  %b2 = getelementptr i64, i64* %b, i32 1
  store i64 %add2, i64* %b2
  ret void
}
