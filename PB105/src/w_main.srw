$PBExportHeader$w_main.srw
forward
global type w_main from window
end type
type cb_filemd52 from commandbutton within w_main
end type
type st_4 from statictext within w_main
end type
type cb_filemd51 from commandbutton within w_main
end type
type mle_outfile from multilineedit within w_main
end type
type st_3 from statictext within w_main
end type
type st_2 from statictext within w_main
end type
type st_1 from statictext within w_main
end type
type ddlb_encoding from dropdownlistbox within w_main
end type
type mle_output from multilineedit within w_main
end type
type mle_input from multilineedit within w_main
end type
type cb_md52 from commandbutton within w_main
end type
type cb_md51 from commandbutton within w_main
end type
type gb_1 from groupbox within w_main
end type
type gb_2 from groupbox within w_main
end type
end forward

global type w_main from window
integer width = 2423
integer height = 1716
boolean titlebar = true
string title = "PowerBuilder Generate  MD5"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
cb_filemd52 cb_filemd52
st_4 st_4
cb_filemd51 cb_filemd51
mle_outfile mle_outfile
st_3 st_3
st_2 st_2
st_1 st_1
ddlb_encoding ddlb_encoding
mle_output mle_output
mle_input mle_input
cb_md52 cb_md52
cb_md51 cb_md51
gb_1 gb_1
gb_2 gb_2
end type
global w_main w_main

type prototypes
Function Boolean CryptBinaryToString ( Blob pbBinary, ULong cbBinary, ULong dwFlags, Ref String pszString, 	Ref ULong pcchString ) Library "crypt32.dll" Alias For "CryptBinaryToStringW"
Function Boolean CryptBinaryToString ( Blob pbBinary, ULong cbBinary, ULong dwFlags, Long pszString, Ref ULong pcchString ) Library "crypt32.dll" Alias For "CryptBinaryToStringW"
Function Boolean CryptStringToBinary ( String pszString, ULong cchString, ULong dwFlags, Ref Blob pbBinary, Ref ULong pcbBinary, Ref ULong pdwSkip, Ref ULong pdwFlags ) Library "crypt32.dll" Alias For "CryptStringToBinaryW"

end prototypes

forward prototypes
public function Encoding wf_getencoding ()
end prototypes

public function Encoding wf_getencoding ();Encoding lEncoding

lEncoding = EncodingANSI! //default

If ddlb_encoding.Text = "EncodingANSI!" Then
	lEncoding = EncodingANSI!
ElseIf ddlb_encoding.Text = "EncodingUTF8!" Then
	lEncoding = EncodingUTF8!
ElseIf ddlb_encoding.Text = "EncodingUTF16LE!" Then
	lEncoding = EncodingUTF16LE!
ElseIf ddlb_encoding.Text = "EncodingUTF16BE!" Then
	lEncoding = EncodingUTF16BE!
End If

Return  lEncoding
end function

on w_main.create
this.cb_filemd52=create cb_filemd52
this.st_4=create st_4
this.cb_filemd51=create cb_filemd51
this.mle_outfile=create mle_outfile
this.st_3=create st_3
this.st_2=create st_2
this.st_1=create st_1
this.ddlb_encoding=create ddlb_encoding
this.mle_output=create mle_output
this.mle_input=create mle_input
this.cb_md52=create cb_md52
this.cb_md51=create cb_md51
this.gb_1=create gb_1
this.gb_2=create gb_2
this.Control[]={this.cb_filemd52,&
this.st_4,&
this.cb_filemd51,&
this.mle_outfile,&
this.st_3,&
this.st_2,&
this.st_1,&
this.ddlb_encoding,&
this.mle_output,&
this.mle_input,&
this.cb_md52,&
this.cb_md51,&
this.gb_1,&
this.gb_2}
end on

on w_main.destroy
destroy(this.cb_filemd52)
destroy(this.st_4)
destroy(this.cb_filemd51)
destroy(this.mle_outfile)
destroy(this.st_3)
destroy(this.st_2)
destroy(this.st_1)
destroy(this.ddlb_encoding)
destroy(this.mle_output)
destroy(this.mle_input)
destroy(this.cb_md52)
destroy(this.cb_md51)
destroy(this.gb_1)
destroy(this.gb_2)
end on

type cb_filemd52 from commandbutton within w_main
integer x = 1733
integer y = 1096
integer width = 539
integer height = 112
integer taborder = 40
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "File MD5 Method 2"
end type

event clicked;Integer  ll_return
String  ls_file, ls_name, ls_txt_file
String ls_err, ls_md5
Int li_ret
nvo_md5 lnvo_md5

ll_return = GetFileSaveName("Select File", ls_file, ls_name, "*.*" , "All Files (*.*),*.*")

If ll_return = 1 Then
	If FileExists ( ls_file ) Then
	Else
		MessageBox("Warning", "Please Choose File")
		Return
	End If
Else
	Return;
End If

ls_err = lnvo_md5.of_md5file( ls_file, ls_md5) 
If ls_err <> "" Then
	mle_outfile.Text = ls_err
Else
	mle_outfile.Text = ls_md5
End If



end event

type st_4 from statictext within w_main
integer x = 114
integer y = 1184
integer width = 343
integer height = 76
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Output Text:"
boolean focusrectangle = false
end type

type cb_filemd51 from commandbutton within w_main
integer x = 1166
integer y = 1096
integer width = 539
integer height = 112
integer taborder = 50
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "File MD5 Method 1"
end type

event clicked;Integer  ll_return
String  ls_file, ls_name, ls_txt_file
String ls_err, ls_md5
Int li_ret
nvo_md5 lnvo_md5

ll_return = GetFileSaveName("Select File", ls_file, ls_name, "*.*" , "All Files (*.*),*.*")

If ll_return = 1 Then
	If FileExists ( ls_file ) Then
	Else
		MessageBox("Warning", "Please Choose File")
		Return
	End If
Else
	Return;
End If

li_ret = lnvo_md5.of_md5file_ole( ls_file, ls_err, ls_md5)
If li_ret = -1 Then
	mle_outfile.Text = ls_err
Else
	mle_outfile.Text = ls_md5
End If



end event

type mle_outfile from multilineedit within w_main
integer x = 105
integer y = 1272
integer width = 2167
integer height = 220
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type st_3 from statictext within w_main
integer x = 119
integer y = 612
integer width = 343
integer height = 76
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Output Text:"
boolean focusrectangle = false
end type

type st_2 from statictext within w_main
integer x = 119
integer y = 288
integer width = 329
integer height = 76
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Input Text:"
boolean focusrectangle = false
end type

type st_1 from statictext within w_main
integer x = 105
integer y = 152
integer width = 315
integer height = 76
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Encoding:"
boolean focusrectangle = false
end type

type ddlb_encoding from dropdownlistbox within w_main
integer x = 421
integer y = 148
integer width = 745
integer height = 400
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
boolean sorted = false
string item[] = {"EncodingANSI!","EncodingUTF8!","EncodingUTF16LE!","EncodingUTF16BE!"}
borderstyle borderstyle = stylelowered!
end type

event constructor;ddlb_encoding.selectitem( 2)
end event

type mle_output from multilineedit within w_main
integer x = 105
integer y = 700
integer width = 2167
integer height = 220
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type mle_input from multilineedit within w_main
integer x = 105
integer y = 368
integer width = 2167
integer height = 220
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
borderstyle borderstyle = stylelowered!
end type

type cb_md52 from commandbutton within w_main
integer x = 1198
integer y = 256
integer width = 686
integer height = 96
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Generate MD5 Method 2"
end type

event clicked;String  ls_input, ls_output
encoding aencoding
nvo_md5 lnvo_md5

mle_output.Text = ""
aencoding = wf_getencoding( )
ls_input = mle_input.Text

If ls_input = "" Or Len(Trim(ls_input)) = 0 Then
	mle_input.setfocus( )
	Return
End If

lnvo_md5.of_md5string(ls_input, ls_output, aencoding) 

mle_output.Text = ls_output

end event

type cb_md51 from commandbutton within w_main
integer x = 1198
integer y = 148
integer width = 686
integer height = 96
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Generate MD5 Method 1"
end type

event clicked;String  ls_input, ls_output
encoding aencoding
nvo_md5 lnvo_md5

mle_output.Text = ""
aencoding = wf_getencoding( )
ls_input = mle_input.Text

If ls_input = "" Or Len(Trim(ls_input)) = 0 Then
	mle_input.setfocus( )
	Return
End If

ls_output =  lnvo_md5.of_md5( ls_input, aencoding)

mle_output.Text = ls_output

end event

type gb_1 from groupbox within w_main
integer x = 14
integer y = 52
integer width = 2350
integer height = 940
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Generate MD5"
end type

type gb_2 from groupbox within w_main
integer x = 14
integer y = 1036
integer width = 2350
integer height = 520
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Check File MD5"
end type

