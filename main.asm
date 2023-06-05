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
    ld a, [rLY]
    cp 144
    jp c, WaitVBlank

    ; LCD の電源を切る
    xor a
    ld [rLCDC], a

    ; 一応サウンドの電源を入れておく
    ld a, $80
    ld [rNR52], a

    ; 音量を最大にしておく
    ld a, $ff
    ld [rNR50], a

    ; 波形メモリ音源以外を無効化
    ld a, %0100_0100
    ld [rNR51], a

    ; 各種音源をキーオフ

    ; 波形メモリチャンネルの設定
    ld a, %10000000
    ld [rNR30], a ; マスターON
    ; NR31 don't care
    ld a, %0010_0000
    ld [rNR32], a ; 音量100%

    ; 周波数設定
    ; 目標とする周波数: 8192Hz（4096Bytes/sec）
    ; 計算式: 2097152 / (2048 - x) 
    ;   -> x = 1792 = %111_0000_0000
    ld a, %0000_0000
    ld [rNR33], a
    ld a, %00000_111
    ld [rNR34], a
    ld a, %10000_111
    ldh [rNR34], a

    ld bc, DataStart ; 読み込み元

    ; CPUは4194304Hz
    ; 1秒間に256回サンプルを書き換えなければならない
    ; ちょうど16384サイクルに1回サンプルを書き換えるとよい

    ; タイマーセット
    ; 4096Hz / 16 = 256Hz
    ld a, $f0
    ldh [rTMA], a
    ldh [rTIMA], a
    ld a, %00000_100
    ld [rTAC], a

    ; 割り込みセット
    ld a, %00000_100
    ld [rIE], a

    ; 現在のバンク
    ld d, $01

    ld a, %0100_0100
    ld [rNR51], a
    xor a
    ldh [rNR12], a
    ldh [rNR22], a
    ei

Loop:
    halt
    nop
    jr Loop

; 450
WriteSamples:
    ; OFF
    xor a ; 4サイクル
    ldh [rNR30], a ; 16サイクル

    call TransferSamples ; 406

    ; ON
    ld a, $FF; 8
    ldh [rNR30], a ; 16
    ld a, $87
    ldh [rNR34], a

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
    ld [rNR52], a
    di
    halt
    stop 
    stop 
    stop

.end
    reti
; end function WriteSamples

; function TransferSamples
; bc レジスタの指すアドレスにある16バイトのサンプルを波形メモリデータ領域にコピーする
; 所要サイクル数はcall/retのオーバヘッドを含めて406サイクル
; この関数を呼ぶ前に必ずキーオフすること
; a, hl レジスタは破壊される
; bc レジスタはサンプルの終端+1を指す
TransferSamples:
    ld hl, $ff30 ; 12サイクル
    ;ld bc, SampleStart ; 12サイクル
rept 16 ; あわせて384サイクル
    ld a, [bc] ; 8サイクル
    ld [hli], a ; 8サイクル
    inc bc ; 8サイクル
endr
    ret ; 4サイクル
; end function TransferSamples

; function Memcpy
; 全てのレジスタの内容は破壊される
; @param de: src
; @param hl: dst
; @param bc: length
Memcpy:
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, Memcpy
    ret
; end function Memcpy

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
