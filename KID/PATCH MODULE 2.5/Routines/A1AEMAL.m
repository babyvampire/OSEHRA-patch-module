A1AEMAL ;isc/jlu-creates the mail message when v or c ;2015-05-30T21:01
 ;;2.5;PATCH MODULE;;Jun 13, 2015
 ;;Submitted to OSEHRA 3 June 2015 by the VISTA Expertise Network
 ;;Licensed under the terms of the Apache License, version 2.0
 ;
 ;
 ;primary change history
 ;2014-03-28: version 2.4 released
 ;
 ;
GET ;Called from A1AEPHS
 I $D(X) S SAVX=X
 ;verified or test remove <<not verified
 I SAVX="v" S MARK=0 D MARK^A1AEM1
 I SAVX="t" S MARK=0 D MARK^A1AEM1
EN ;
 K A1AEPD2
 S $P(AEQ,"=",78)=""
 S A1AEJH=^A1AE(11005,DA,0)
 S A1AEPD=$P(A1AEJH,U),A1AEVR=$P(A1AEPD,"*",2)
 I '$P(A1AEPD,"*",3) S A1AEPD2=$P($G(^A1AE(11005,DA,4)),U)
 S XMSUB=$S($P(A1AEJH,U,7)="e":"EMERGENCY ",1:"")_$S(A1AENEW="v":"Released",1:"Completed/NotReleased")_" "_$S($D(A1AEPD2):A1AEPD2,1:A1AEPD)
 I A1AEVR=999 S XMSUB=$P(XMSUB,"999")_"DBA"_$P(XMSUB,"999",2)
 I $G(TESTMES) S XMSUB=$S($D(A1AEPD2):A1AEPD2,1:A1AEPD)_" "_TXVER
 ;if not called from a1aephs must have pkif
 S SEQ=$P(A1AEJH,"^",6) I SEQ S SEQ="SEQ #"_SEQ
 ;seq "" till verified when not adding seq to complete
 K XMZ S XMDUZ="National Patch Module",XMSUB=XMSUB_" "_SEQ
 D XMZ^XMA2 K XMDUZ I XMZ=-1 W !?5,"Failed to get get message number",! K SEQ,XMZ
 Q
 ;
ADD(T) ;Inc E, Add text to Message. Also called from A1AEUTL2
        I $G(A1AEPRNT)=1 W T,! Q  ; From A1AE STANDARD PRINT template
 S E=E+1,^XMB(3.9,XMZ,2,E,0)=T
 Q
 ;
MES ;Build message, Called from A1AEPHS
 S JL=A1AENEW,E=1 ;Start E at 1, Line 1 gets $TXT
 D ADD(AEQ)
        N STRMABBR S STRMABBR=$$STRMABBR^A1AEPH2(DA)
        N RD
        S RD="Run Date: "_$$LJ^XLFSTR($$EDT($S($G(A1AERCR8):$P(A1AEJH,U,11),1:$$DT^XLFDT)),33)
        I $L(STRMABBR) D
        . N STRM S STRM="Stream: "_$$LJ^XLFSTR(STRMABBR,10)
        . S RD=$E(RD,1,25)_STRM
        ;
 D ADD(RD_"Designation: "_$S($D(A1AEPD2):A1AEPD2,1:A1AEPD))
        K RD
 S A1AEJ1=^DIC(9.4,$P(A1AEJH,U,2),0),A1AEJP=$P(A1AEJH,U,7),A1AEJP=$S(A1AEJP="p":"Patch for a Patch",A1AEJP="n":"Not Urgent",A1AEJP="m":"Mandatory",A1AEJP="e":"EMERGENCY",A1AEJP="i":"Informational",1:"")
 S AJL=$P(A1AEJ1,U,2)_" - "_$P(A1AEJ1,U)
 S AJL=$$LJ^XLFSTR($E(AJL,1,35),36)
 D ADD("Package : "_AJL_"Priority: "_A1AEJP)
 S AJL=$$LJ^XLFSTR($P(A1AEJH,U,3)_$J(SEQ,15),38)
 D ADD("Version : "_AJL_"Status: "_$$STATUS2E^A1AEPH2(JL))
 I $P(A1AEJH,U,18) D ADD("                  Compliance Date: "_$$EDT($P(A1AEJH,U,18)))
 D ADD(AEQ)
 D ADD("")
 I $D(^A1AE(11005,DA,"Q","B")) K AZ S D0=DA D PCHK^A1AEUTL1 ;Returns AZ
 I $D(AZ)=11 D PCHK^A1AEMAL1 K AZ,AN
        ; VEN/SMH - Next lines are new. Mirror what's in the Print Template A1AE STANDARD PRINT
        I $P(^A1AE(11005,DA,0),U,20) D  ; Print Patch Stream
        . N %,Y
        . D ADD("")
        . S %=$G(^A1AE(11005,DA,0)),Y=$P(%,U,20),Y=$S(Y="":Y,$D(^A1AE(11007.1,Y,0))#2:$P(^(0),U),1:Y)
        . D ADD("Source: "_Y)
        I $P(^A1AE(11005,DA,5),U,2) D  ; Print Dervied From Patch
        . N %,Y
        . D ADD("")
        . S %=$G(^A1AE(11005,DA,5)),Y=$P(%,U,2),Y=$S(Y="":Y,$D(^A1AE(11005,Y,0))#2:$P(^(0),U),1:Y)
        . D ADD("Derived from Patch: "_Y)
        ; VEN/SMH - End
 D ADD("")
 D ADD("Subject: "_$P(A1AEJH,U,5))
 D ADD("")
 D ADD("Category: ")
 I '$D(ZTQUEUED) W !?3,"." R ZZ:0
 S D1=0,A1B="  - "
 F  S D1=$O(^A1AE(11005,DA,"C",D1)) Q:'D1  D SJ D ADD(A1B_J)
 D ADD("")
 ;
 D ADD("Description:")
 D ADD("============")
 D ADD("")
 S D1=0
 F  S D1=$O(^A1AE(11005,DA,"D",D1)) Q:'D1  D ADD(" "_^(D1,0))
 D ADD("")
 ;
 D ADD("Routine Information:")
 D ADD("====================")
 D RTNINFO
 D ADD("")
 ;
 D ADD(AEQ)
 D ADD("User Information:"_$S($P(A1AEJH,U,17):$$RJ^XLFSTR("Hold Date     : ",42)_$$EDT($P(A1AEJH,U,17)),1:""))
 D ADD($$WHOWHEN("Entered",$P(A1AEJH,U,9),$P(A1AEJH,U,12)))
 D ADD($$WHOWHEN("Completed",$S(JL="c":DUZ,JL="v":$P(A1AEJH,U,13),1:""),$S(JL="c":$P(DT,"."),JL="v":$P(A1AEJH,U,10),1:"")))
 D ADD($$WHOWHEN("Released",$S($G(A1AERCR8):$P(A1AEJH,U,14),JL="v":DUZ,1:""),$S($G(A1AERCR8):$P(A1AEJH,U,11),JL="v":$P(DT,"."),1:"")))
        ;
        I "^i2^d2^s2^r2^n2^"[(U_JL_U) D USERS(DA)
        ;
 D ADD(AEQ)
 I '$D(ZTQUEUED) W " ." R ZZ:0
 ;Add the KIDS build to Mail message
 D ^A1AEMAL1
 ;
 I '$G(A1AERCR8) D
 . K XMZ
 . W !,"NOTE: A message has been sent to the",$S(A1AENEW="c":" CS Team",A1AENEW="v":" Network Mail groups",1:" Test Site Users")_$S(A1AENEW="c":" for this package",1:" for distribution.")
 K A1AEPD,A1AEVR,%H,A1AED,A1AEDC,A1AEDV,A1AEJ1,A1AEJH,A1AEJP,A1B,A1CB,A1CV,A1US,AJL,AJL1,E,J,JL,JSP,XMTEXT,XMY,D2,D1,AN,ZZ,AEQ
 I $G(TESTMES) W !,"      Please use mailman if you need to forward this message again."
 W ! I $D(SAVX) S X=SAVX K SAVX
 Q
SJ ;
 S J=^A1AE(11005,DA,"C",D1,0),J=$S(J="d":"Data Dictionary",J="i":"Input Template",J="p":"Print Template",J="r":"Routine",J="s":"Sort Template",J="o":"Other",J="db":"Database",J="e":"e",J="pp":"PATCH FOR A PATCH",J="inf":"Informational",1:"")
 I J="e" S J="Enhancement ("_$S($P(^A1AE(11005,DA,0),"^",7)="m":"Mandatory",$P(^(0),"^",7)="n":"Optional",1:"")_")"
 Q
 ;
EDT(FMDT) ;
 Q $$UP^XLFSTR($$FMTE^XLFDT(FMDT))
 ;
USERS(DA)   ; Extra users
        ; VEN/SMH - This is new for the new statuses
        ; TODO: This happens during input transform. These fields WILL NOT be populated yet on the first pass.
        ; Fileman filing happens after the input transform but b4 xreffing.
        N USER,DATE
        S USER=$$GET1^DIQ(11005,DA,8.1,"I") ; Rev usr
        S DATE=$$GET1^DIQ(11005,DA,8.09,"I") ; Rev Date
        D ADD($$WHOWHEN("Reviewed",USER,DATE)) ; Always print
        S USER=$$GET1^DIQ(11005,DA,8.12,"I") ; Sec Dev usr
        S DATE=$$GET1^DIQ(11005,DA,8.11,"I") ; Sec Dev date
        I DATE D ADD($$WHOWHEN("Sec Dev",USER,DATE)) ; print if there is a value
        S USER=$$GET1^DIQ(11005,DA,8.14,"I") ; Sec Com usr
        S DATE=$$GET1^DIQ(11005,DA,8.13,"I") ; Sec Com date
        I DATE D ADD($$WHOWHEN("Sec Com",USER,DATE)) ; ditto
        S USER=$$GET1^DIQ(11005,DA,8.16,"I") ; Sec Rel usr
        S DATE=$$GET1^DIQ(11005,DA,8.15,"I") ; Sec Rel date
        I DATE D ADD($$WHOWHEN("Sec Rel",USER,DATE)) ; ditto
        S USER=$$GET1^DIQ(11005,DA,8.18,"I") ; Sec Deny usr
        S DATE=$$GET1^DIQ(11005,DA,8.17,"I") ; Sec Deny date
        I DATE D ADD($$WHOWHEN("Denied",USER,DATE)) ; ditto
        QUIT
        ;
WHOWHEN(WHAT,WHO,WHEN) ;
 N LINE
 S LINE=$$LJ^XLFSTR(WHAT_" By",12)_": "
 S LINE=LINE_$$LJ^XLFSTR($S(+WHO:$E($$NAME^XMXUTIL(WHO),1,29),1:""),30)
 S LINE=LINE_$$LJ^XLFSTR("Date "_WHAT,14)_": "
 Q LINE_$S(+WHEN:$$EDT(WHEN),1:"")
 ;
RTNINFO ;Put the routine info out
 N D0 S D0=DA D RTNINFO^A1AEUTL2(1)
 Q
