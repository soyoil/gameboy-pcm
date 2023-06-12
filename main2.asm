include "hardware.inc/hardware.inc"

section "Int", rom0[$50]
    jp WriteSamples
    reti
; end section "Int"

section "Header", rom0[$100]
    nop
    jp EntryPoint
    NINTENDO_LOGO
    ds $150 - @, 0
; end section "Header"

EntryPoint:

WaitVBlank:
    ldh a, [rLY]
    cp 144
    jp c, WaitVBlank

    ; LCD の電源を切る
    xor a
    ldh [rLCDC], a

    ; 一応サウンドの電源を入れておく
    ld a, $80
    ldh [rNR52], a

    ; 音量を最大にしておく
    ld a, $ff
    ldh [rNR50], a

    ; ch1以外を無効化
    ld a, %0001_0001
    ldh [rNR51], a

    ; ch1の設定
    ld a, %01110000
    ldh [rNR10], a ; スイープOFF
    ld a, %11000000
    ldh [rNR11], a ; デューティー比75%
    ld a, %00001000
    ldh [rNR12], a ; エンベロープ上昇
    ld a, $ff
    ldh [rNR13], a
    ld a, %00000111
    ldh [rNR14], a ; 周波数最高

    ld bc, DataStart ; 読み込み元

    ; CPUは4194304Hz
    ; 1秒間に8192回サンプルを書き換えなければならない
    ; ちょうど512サイクルに1回サンプルを書き換えるとよい

    ; タイマーセット
    ld a, $fc
    ldh [rTMA], a
    ldh [rTIMA], a
    ld a, %00000_111
    ldh [rTAC], a

    ; 割り込みセット
    ld a, %00000_100
    ldh [rIE], a

    ; 現在のバンク
    ld d, $01
    ; 上位か下位か
    ld e, 0 ; ゼロなら上位

    ld a, %0001_0001
    ldh [rNR51], a
    xor a
    ldh [rNR22], a
    ldh [rNR32], a
    ei

Loop:
    halt
    nop
    nop
    jr Loop

; 450
WriteSamples:
    ; 上位→下位の順
    xor a
    ld a, [bc] ; フェッチではフラグが不変
    cp a, e ; 
    jr nz, .jump ; 上位ならそのまま、下位ならジャンプ
    ; e = 0
    inc e
    jr .endif
.jump
    ; e = 1
    ; 下位なら上位にする
    swap a
    dec e
    inc bc
.endif 

    ; 上位4バイト取り出し
    and a, %11110000

    ; エンベロープ上昇設定
    or a, %00001000

    ; かきこみ
    ldh [rNR12], a
    ; ON
    ld a, %10000111
    ldh [rNR14], a

    ; bc レジスタが $8000 に到達したかどうか調べる
    ld a, $80
    cp a, b
    jp nz, .end
    
    ; もし到達していればバンクを切り替えて bc をリセット
    inc d
    ld h, $20
    ld [hl], d
    ld bc, $4000

    ; 最終バンクに到達していたら処理終了
    ld a, 24
    cp a, d
    jp nz, .end
    xor a
    ldh [rNR52], a
    di
    halt
    stop 
    stop 
    stop

.end
    reti
; end function WriteSamples


section "Data1", romx, bank[1]
DataStart:
    incbin "bank1.bin"
DataEnd:

section "Data2", romx, bank[2]
    incbin "bank2.bin"
section "Data3", romx, bank[3]
    incbin "bank3.bin"
section "Data4", romx, bank[4]
    incbin "bank4.bin"
section "Data5", romx, bank[5]
    incbin "bank5.bin"
section "Data6", romx, bank[6]
    incbin "bank6.bin"
section "Data7", romx, bank[7]
    incbin "bank7.bin"
section "Data8", romx, bank[8]
    incbin "bank8.bin"
section "Data9", romx, bank[9]
    incbin "bank9.bin"
section "Data10", romx, bank[10]
    incbin "bank10.bin"
section "Data11", romx, bank[11]
    incbin "bank11.bin"
section "Data12", romx, bank[12]
    incbin "bank12.bin"
section "Data13", romx, bank[13]
    incbin "bank13.bin"
section "Data14", romx, bank[14]
    incbin "bank14.bin"
section "Data15", romx, bank[15]
    incbin "bank15.bin"
section "Data16", romx, bank[16]
    incbin "bank16.bin"
section "Data17", romx, bank[17]
    incbin "bank17.bin"
section "Data18", romx, bank[18]
    incbin "bank18.bin"
section "Data19", romx, bank[19]
    incbin "bank19.bin"
section "Data20", romx, bank[20]
    incbin "bank20.bin"
section "Data21", romx, bank[21]
    incbin "bank21.bin"
section "Data22", romx, bank[22]
    incbin "bank22.bin"
section "Data23", romx, bank[23]
    incbin "bank23.bin"
