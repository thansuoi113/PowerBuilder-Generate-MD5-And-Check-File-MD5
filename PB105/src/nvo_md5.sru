$PBExportHeader$nvo_md5.sru
forward
global type nvo_md5 from nonvisualobject
end type
type md5_ctx from structure within nvo_md5
end type
end forward

type md5_ctx from structure
	byte a [8]
	byte b [16]
	byte c [64]
	byte d [16]
end type

shared variables

end variables

global type nvo_md5 from nonvisualobject autoinstantiate
end type

type prototypes
//method 1
Function Long OpenProcess (Long dwDesiredAccess, Long bInheritHandle, Long dwProcessId) Library "kernel32.dll" Alias For "OpenProcess; ansi"
Function Boolean CloseHandle (Long hObject) Library "kernel32" Alias For "CloseHandle; ansi"

Function ULong CreateFile (Ref String lpFileName, ULong dwDesiredAccess, ULong dwShareMode, Ref ULong lpSecurityAttributes [3], ULong dwCreationDisposition, ULong dwFlagsAndAttributes, ULong hTemplateFile) Library "kernel32.dll" Alias For "CreateFileA; ansi"
Function ULong CreateFileMapping (ULong hFile, ULong lpFileMappigAttributes[3], ULong flProtect, ULong dwMaximumSizeHigh, ULong dwMaximumSizeLow, Ref String lpName) Library "kernel32" Alias For "CreateFileMappingA; ansi"
//Function ULong CreateFileMapping(ULong hFile,Ref SECURITY_ATTRIBUTES lpFileMappigAttributes,ULong flProtect,ULong dwMaximumSizeHigh,ULong dwMaximumSizeLow,Ref String lpName) Library "kernel32.dll" Alias For "CreateFileMappingA"
Function ULong OpenFileMapping (ULong dwDesiredAccess, Boolean bInheritHandle, Ref String lpName) Library "kernel32" Alias For "OpenFileMappingA; ansi"
Function ULong MapViewOfFile (ULong hFileMappingObject, ULong dwDesiredAccess, ULong dwFileOffsetHigh, ULong dwFileOffsetLow, ULong dwNumberOfBytesToMap) Library "kernel32" Alias For "MapViewOfFile"
Subroutine UnmapViewOfFile (ULong lpBaseAddress) Library "kernel32" Alias For "UnmapViewOfFile; ansi"

Subroutine MD5Init (Ref md5_ctx lpContext) Library "cryptdll.dll" Alias For "MD5Init; ansi"
Subroutine MD5Final (Ref md5_ctx lpContext) Library "cryptdll.dll" Alias For "MD5Final; ansi"
Subroutine MD5Update (Ref md5_ctx lpContext, ULong lpBuffer, ULong BufSize) Library "cryptdll.dll" Alias For "MD5Update; ansi"
Subroutine MD5Update (Ref md5_ctx lpContext, Blob lpBuffer, ULong BufSize) Library "cryptdll.dll" Alias For "MD5Update; ansi"

//method 2
Function Boolean CryptAcquireContextA (Ref ULong hProv, Ref String pszContainer,  Ref String pszProvider, ULong dwProvType,  ULong dwFlags) Library "advapi32.dll"
Function Boolean CryptReleaseContext (ULong hProv, ULong dwFlags)   Library "advapi32.dll"
Function Boolean CryptCreateHash (ULong hProv, UInt Algid, ULong hKey,  ULong dwFlags, Ref ULong phHash)  Library "advapi32.dll"
Function Boolean CryptHashData (ULong hHash,  Ref String pbData,  ULong dwDataLen, ULong dwFlags) Library "advapi32.dll"
Function Boolean CryptHashData (ULong hHash,  Ref Blob pbData,   ULong dwDataLen, ULong dwFlags)  Library "advapi32.dll"
Function Boolean CryptDestroyHash (ULong hHash)  Library "advapi32.dll"
Function Boolean CryptGetHashParam (ULong hHash, ULong dwParam,  Ref Blob pbData,  Ref ULong pdwDataLen, ULong dwFlags) Library "advapi32.dll"
Function ULong GetLastError () Library "kernel32.dll"

end prototypes
type variables
Constant ULong GENERIC_READ = 2147483648
Constant ULong FILE_SHARE_READ = 1
Constant ULong OPEN_EXISTING = 3
Constant ULong FILE_ATTRIBUTE_NORMAL = 128
Constant ULong PAGE_READONLY = 2
Constant ULong FILE_MAP_READ = 4

Constant ULong PROV_RSA_FULL = 1
Constant ULong CRYPT_VERIFYCONTEXT  =  4026531840 // 0xF0000000
Constant ULong CALG_MD5 = 32771 // 4<<13 | 0 | 3
Constant ULong HP_HASHVAL = 2 //  0x0002

end variables

forward prototypes
public function string decto (decimal ad_dec, readonly unsignedinteger aui_sys)
public function integer hexencode (ref byte lb_array[], ref character lc_result[])
public function string of_md5_10before (string as_text)
public function string of_md5 (string as_text)
public function string of_md5 (blob abl_text)
public function integer of_md5file_ole (string as_filepath, string as_hata, ref string as_md5)
public function string of_md5file (ref string ls_filename, ref string ls_result)
public function string of_md5string (ref string ls_string, ref string ls_result)
public function string of_md5 (string as_text, encoding aencoding)
public function string of_md5string (ref blob abl_string, ref string ls_result)
public function string of_md5string (ref string ls_string, ref string ls_result, encoding aencoding)
end prototypes

public function string decto (decimal ad_dec, readonly unsignedinteger aui_sys);//====================================================================
// Function: nvo_md5.decto()
//--------------------------------------------------------------------
// Description: NextEnd
//--------------------------------------------------------------------
// Arguments:
// 	value   	decimal        	ad_dec 	
// 	readonly	unsignedinteger	aui_sys	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2022/01/09
//--------------------------------------------------------------------
// Usage: nvo_md5.decto ( decimal ad_dec, readonly unsignedinteger aui_sys )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

String ls_ret //Returned result
String ls_dec
String ls_left, ls_right, ls_mod
UInt ld_mod/* The remainder is an integer */
Dec ld_mul //Take the product of decimals as dec
Int i, li_pos, li_len, li_pointpos, li_maxpower, li_minpower

If IsNull (ad_dec) Or IsNull (aui_sys) Or aui_sys < 2 Then Goto NextEnd

ls_dec = String (ad_dec)
li_pointpos = Pos (ls_dec, '.')

If li_pointpos = 0 Then
	
	If ad_dec < aui_sys Then //greater than 10 decimal
		If ad_dec <= 9 Then
			ls_ret = String (ad_dec)
			Goto NextEnd
		ElseIf ad_dec > 9 And ad_dec < aui_sys Then
			ls_ret = Char (64-9 + ad_dec) //Numbers greater than 9 are converted to letters
			Goto NextEnd
		End If
	Else
		Do
			ld_mod = Mod (ad_dec, aui_sys) //take the remainder
			ls_mod = decto (ld_mod, aui_sys)
			ls_ret = ls_mod + ls_ret
			
			ad_dec = Long ((ad_dec - ld_mod)/aui_sys) //Go to the quotient
			
		Loop Until ad_dec < aui_sys
		
		If ad_dec > 9 Then
			ls_ret = Char (64-9 + ad_dec) + ls_ret
		Else
			ls_ret = String (ad_dec) + ls_ret
		End If
		
	End If
Else
	ls_left = Mid (ls_dec, 1, li_pointpos) //take integer
	ls_right = Mid (ls_dec, li_pointpos) //decimal
	ls_ret = decto (Dec (ls_left), aui_sys) + '.' //integer part conversion
	
	ld_mul = Dec (ls_right)
	For i = 1 To 10 //Maximum accuracy is 10
		ld_mul = ld_mul * aui_sys
		ls_ret = ls_ret + String (Int (ld_mul)) //round
		If ld_mul = Int (ld_mul) Then Exit //No remainder
		ld_mul = ld_mul - Int (ld_mul) //Remove integer
	Next
	
End If

NextEnd:
Return ls_ret


end function

public function integer hexencode (ref byte lb_array[], ref character lc_result[]);//====================================================================
// Function: nvo_md5.hexencode()
//--------------------------------------------------------------------
// Description: Convert characters to hexadecimal encoding
//--------------------------------------------------------------------
// Arguments:
// 	reference	byte     	lb_array[] 		 is the character to be converted
// 	reference	character	lc_result[]	 encoding in the source character
//--------------------------------------------------------------------
// Returns:  integer hexadecimal encoding
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2022/01/09
//--------------------------------------------------------------------
// Usage: nvo_md5.hexencode ( ref byte lb_array[], ref character lc_result[] )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Long l_len, i, l_num
Char lc_temp [2]

l_len = UpperBound (lb_array [])

For i = 1 To l_len
	l_num = (2 * i)-1
	If lb_array [i] < 16 Then //If less than 16, add 0
		lc_temp [1] = '0'
		lc_temp [2] = decto (lb_array [i], 16)
	Else
		lc_temp [] = decto (lb_array [i], 16)
	End If
	lc_result [l_num] = lc_temp [1]
	lc_result [l_num + 1] = lc_temp [2]
Next

Return l_len * 2
end function

public function string of_md5_10before (string as_text);//====================================================================
// Function: nvo_md5.of_md5_10before()
//--------------------------------------------------------------------
// Description: Calculate the MD5 message digest hash of a string Using the Windows Crypto API
// PB7/8/9
//--------------------------------------------------------------------
// Arguments:
// 	value	string	as_text	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2022/01/09
//--------------------------------------------------------------------
// Usage: nvo_md5.of_md5_10before ( string as_text )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

ULong MD5LEN = 16
ULong hProv // provider handle
ULong hHash // hash object handle
ULong err_number
String ls_result, ls_null
Integer i, l, r, b
Blob{16} bl_hash
Blob{1} bl_byte

SetNull (ls_null)
ULong cbHash = 0
Char HexDigits[0 To 15] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}

//Get handle to the crypto provider
If Not CryptAcquireContextA(hProv, ls_null, ls_null, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) Then
	err_number = GetLastError()
	Return 'acquire context failed ' + String (err_number)
End If

// Create the hash object
If Not CryptCreateHash(hProv, CALG_MD5, 0, 0, hHash) Then
	err_number = GetLastError()
	CryptReleaseContext(hProv, 0)
	Return 'create hash failed ' + String (err_number)
End If


// Add the input to the hash
If Not CryptHashData(hHash, as_text, Len(as_text), 0) Then
	err_number = GetLastError()
	CryptDestroyHash(hHash)
	CryptReleaseContext(hProv, 0)
	Return 'hashdata failed ' + String (err_number)
End If

// Get the hash value and convert it to readable characters
cbHash = MD5LEN
If (CryptGetHashParam(hHash, HP_HASHVAL, bl_hash, cbHash, 0)) Then
	For i = 1 To 16
		bl_byte = BlobMid (bl_hash, i, 1)
		b = Asc (String(bl_byte))
		r = Mod (b, 16) // right 4 bits
		l = b / 16 // left 4 bits
		ls_result += HexDigits [l] + HexDigits [r]
	Next
Else
	err_number = GetLastError()
	Return 'gethashparam failed ' + String (err_number)
End If

// clean up and return
CryptDestroyHash(hHash)
CryptReleaseContext(hProv, 0)

Return ls_result


end function

public function string of_md5 (string as_text);//====================================================================
// Function: nvo_md5.of_md5()
//--------------------------------------------------------------------
// Description:
//--------------------------------------------------------------------
// Arguments:
// 	value	string	as_text	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2022/01/09
//--------------------------------------------------------------------
// Usage: nvo_md5.of_md5 ( string as_text )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Blob lbl_text
lbl_text = Blob(as_text, EncodingUTF8!)
Return of_md5(lbl_text)
end function

public function string of_md5 (blob abl_text);//====================================================================
// Function: nvo_md5.of_md5()
//--------------------------------------------------------------------
// Description: Calculate the MD5 message digest hash of a string Using the Windows Crypto API ( PB 10 later)
//--------------------------------------------------------------------
// Arguments:
// 	value	blob	abl_text	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2022/01/09
//--------------------------------------------------------------------
// Usage: nvo_md5.of_md5 ( blob abl_text )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

ULong MD5LEN = 16
ULong hProv // provider handle
ULong hHash // hash object handle
ULong err_number
String ls_result, ls_null
Integer i, l, r, b
Blob{16} bl_hash
Blob{1} bl_byte

SetNull (ls_null)
ULong cbHash = 0
Char HexDigits[0 To 15] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}

//Get handle to the crypto provider
If Not CryptAcquireContextA(hProv, ls_null, ls_null, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) Then
	err_number = GetLastError()
	Return 'acquire context failed ' + String (err_number)
End If

// Create the hash object
If Not CryptCreateHash(hProv, CALG_MD5, 0, 0, hHash) Then
	err_number = GetLastError()
	CryptReleaseContext(hProv, 0)
	Return 'create hash failed ' + String (err_number)
End If

// Add the input to the hash
If Not CryptHashData(hHash, abl_text, Len(abl_text), 0) Then
	err_number = GetLastError()
	CryptDestroyHash(hHash)
	CryptReleaseContext(hProv, 0)
	Return 'hashdata failed ' + String (err_number)
End If

// Get the hash value and convert it to readable characters
cbHash = MD5LEN
If (CryptGetHashParam(hHash, HP_HASHVAL, bl_hash, cbHash, 0)) Then
	For i = 1 To 16
		bl_byte = BlobMid (bl_hash, i, 1)
		b = AscA(String(bl_byte,EncodingANSI!))
		r = Mod (b, 16) // right 4 bits
		l = b / 16 // left 4 bits
		ls_result += HexDigits [l] + HexDigits [r]
	Next
Else
	err_number = GetLastError()
	Return 'gethashparam failed ' + String (err_number)
End If

// clean up and return
CryptDestroyHash(hHash)
CryptReleaseContext(hProv, 0)

Return ls_result


end function

public function integer of_md5file_ole (string as_filepath, string as_hata, ref string as_md5);//====================================================================
// Function: nvo_md5.of_md5file_ole()
//--------------------------------------------------------------------
// Description:
//--------------------------------------------------------------------
// Arguments:
// 	value    	string	as_filepath	
// 	value    	string	as_hata    	
// 	reference	string	as_md5     	
//--------------------------------------------------------------------
// Returns:  integer
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2022/01/09
//--------------------------------------------------------------------
// Usage: nvo_md5.of_md5file_ole ( string as_filepath, string as_hata, ref string as_md5 )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

OLEObject obj_md5, obj_stream, obj_dom, obj_element
Integer li_rc, li_temp

If IsNull( as_filepath ) Then
	as_hata = "File Path returned null!"
	Return -1
End If

li_temp = 1 //Initial Value

obj_md5 = Create OLEObject
li_rc = obj_md5.ConnectToNewObject("System.Security.Cryptography.MD5CryptoServiceProvider")
If li_rc = 0 Then //Success
	obj_stream = Create OLEObject
	li_rc = obj_stream.ConnectToNewObject("ADODB.Stream")
	Choose Case li_rc
		Case 0
			obj_stream.Open
			obj_stream.Type = 1
			obj_stream.LoadFromFile(as_filepath)
			
			obj_md5.ComputeHash_2(obj_stream.Read)
			
			obj_dom = Create OLEObject
			li_rc = obj_dom.ConnectToNewObject("Msxml2.DOMDocument.6.0")
			If li_rc = 0 Then
				obj_element = obj_dom.CreateElement("tmp") //Gecici Element Olusturma	
				obj_element.DataType = "bin.hex" //Cevirme	 
				obj_element.NodeTypedValue = obj_md5.Hash
				
				as_md5 = obj_element.Text //Cevirilmis MD5 Degeri Alma		
			Else
				li_temp = -1
				as_hata = "Msxml2.DOMDocument.6.0 has received an error! li_rc : " + String(li_rc)
			End If
			
			obj_stream.Close
		Case Else
			li_temp = -1
			as_hata = "ADODB.Stream has received an error! li_rc : " + String(li_rc)
	End Choose
Else
	li_temp = -1
	as_hata = "MD5CryptoServiceProvider has received an error! li_rc : " + String(li_rc)
End If

Destroy obj_dom
Destroy obj_stream
Destroy obj_md5
Return li_temp

end function

public function string of_md5file (ref string ls_filename, ref string ls_result);//====================================================================
// Function: nvo_md5.of_md5file()
//--------------------------------------------------------------------
// Description:
//--------------------------------------------------------------------
// Arguments:
// 	reference	string	ls_filename	
// 	reference	string	ls_result  	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2022/01/09
//--------------------------------------------------------------------
// Usage: nvo_md5.of_md5file ( ref string ls_filename, ref string ls_result )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

ULong lul_size
ULong lul_hfile, lul_hmap, lul_pAddr
Long ll_ret
ULong lul_Secu [3]
md5_ctx lpContext
Char lc_result []
byte lbyte_result []
String ls_ref, ls_errtext
Boolean lb_ret

ls_result = ''
ls_filename = String (ls_filename, '')

If DirectoryExists (ls_filename) = True Then
	ls_errtext = 'Cannot be a folder!' //+ string (ls_filename) + '~ r ~ n'
	Goto NextEnd
End If

If FileExists (ls_filename) = False Then
	ls_errtext = 'File does not exist!' //+ string (ls_filename) + '~ r ~ n'
	Goto NextEnd
End If

lul_size = FileLength (ls_filename)
If lul_size = -1 Then
	ls_errtext = 'FileLength:' + String (lul_size) + '~ r ~ n'
	Goto NextEnd
End If

If lul_size = 0 Then
	ls_errtext = 'File content cannot be empty:' + String (lul_size) + '~ r ~ n'
	Goto NextEnd
End If

If lul_size > 2 * 645 * 1024 * 1024 Then //Maximum support
	ls_errtext = 'Max support:' + String (2 * 645 * 1024 * 1024, '###, ###, ## 0') + '~ r ~ n'
	Goto NextEnd
End If

Try
	
	lul_hfile = CreateFile (ls_filename, GENERIC_READ, FILE_SHARE_READ, lul_Secu [], OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0)
	If lul_hfile <= 0 Then
		ls_errtext = 'CreateFile:' + String (lul_hfile) + '~ r ~ n'
		THROW Create runtimeerror
	End If
	
	lul_hmap = CreateFileMapping (lul_hfile, lul_Secu, PAGE_READONLY, 0, 0, ls_ref)
	If lul_hmap <= 0 Then
		ls_errtext = 'CreateFileMapping:' + String (lul_hmap) + '~ r ~ n'
		THROW Create runtimeerror
	End If
	
	lul_pAddr = MapViewOfFile (lul_hmap, FILE_MAP_READ, 0,0, lul_size);
	If lul_pAddr <= 0 Then
		ls_errtext = 'MapViewOfFile:' + String (lul_pAddr) + '~ r ~ n'
		THROW Create runtimeerror
	End If
	
	MD5Init (lpContext)
	MD5Update (lpContext, lul_pAddr, lul_size)
	MD5Final (lpContext)
	
Catch (runtimeerror e)
	ls_errtext += e.getmessage ()
Finally
	
	If lul_pAddr > 0 Then
		UnmapViewOfFile (lul_pAddr);
		lul_pAddr = 0
	End If
	
	If lul_hmap > 0 Then
		lb_ret = CloseHandle (lul_hmap)
		If lb_ret = False Then
			ls_errtext += 'CloseHandle:' + String (lb_ret) + '~ r ~ n'
			//goto e
		Else
			lul_hmap = 0
		End If
	End If
	
	If lul_hfile > 0 Then
		lb_ret = CloseHandle (lul_hfile)
		If lb_ret = False Then
			ls_errtext += 'CloseHandle:' + String (lb_ret) + '~ r ~ n'
			//goto e
		Else
			lul_hfile = 0
		End If
	End If
	
End Try

If ls_errtext <> '' Then Goto NextEnd

lbyte_result [] = lpContext.b []
hexencode (lbyte_result [], lc_result [])
ls_result = lc_result []

Return ''

Goto NextEnd
NextEnd:

Return ls_errtext


end function

public function string of_md5string (ref string ls_string, ref string ls_result);//====================================================================
// Function: nvo_md5.of_md5string()
//--------------------------------------------------------------------
// Description:
//--------------------------------------------------------------------
// Arguments:
// 	reference	string	ls_string	
// 	reference	string	ls_result	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2022/01/09
//--------------------------------------------------------------------
// Usage: nvo_md5.of_md5string ( ref string ls_string, ref string ls_result )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Blob lblob_string
lblob_string = Blob (ls_string, encodingutf8!)
of_md5string (lblob_string, ls_result)
Return ''

end function

public function string of_md5 (string as_text, encoding aencoding);//====================================================================
// Function: nvo_md5.of_md5()
//--------------------------------------------------------------------
// Description:
//--------------------------------------------------------------------
// Arguments:
// 	value	string  	as_text  	
// 	value	Encoding	aEncoding	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2022/01/09
//--------------------------------------------------------------------
// Usage: nvo_md5.of_md5 ( string as_text, encoding aencoding )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Blob lbl_text
lbl_text = Blob(as_text, aEncoding)
Return of_md5(lbl_text)
end function

public function string of_md5string (ref blob abl_string, ref string ls_result);//====================================================================
// Function: nvo_md5.of_md5string()
//--------------------------------------------------------------------
// Description:
//--------------------------------------------------------------------
// Arguments:
// 	reference	blob  	abl_string	
// 	reference	string	ls_result 	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2022/01/09
//--------------------------------------------------------------------
// Usage: nvo_md5.of_md5string ( ref blob abl_string, ref string ls_result )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

ULong lul_size
md5_ctx lpContext
Char lc_result []
byte lbyte_result []
ls_result = ''
lul_size = Len (abl_string)

MD5Init (lpContext)
MD5Update (lpContext, abl_string, lul_size)
MD5Final (lpContext)

lbyte_result [] = lpContext.b []
hexencode (lbyte_result [], lc_result [])
ls_result = lc_result []

Return ''

end function

public function string of_md5string (ref string ls_string, ref string ls_result, encoding aencoding);//====================================================================
// Function: nvo_md5.of_md5string()
//--------------------------------------------------------------------
// Description:
//--------------------------------------------------------------------
// Arguments:
// 	reference	string  	ls_string	
// 	reference	string  	ls_result	
// 	value    	encoding	aencoding	
//--------------------------------------------------------------------
// Returns:  string
//--------------------------------------------------------------------
// Author:	PB.BaoGa		Date: 2022/01/09
//--------------------------------------------------------------------
// Usage: nvo_md5.of_md5string ( ref string ls_string, ref string ls_result, encoding aencoding )
//--------------------------------------------------------------------
//	Copyright (c) PB.BaoGa(TM), All rights reserved.
//--------------------------------------------------------------------
// Modify History:
//
//====================================================================

Blob lblob_string
lblob_string = Blob (ls_string, aencoding)
of_md5string (lblob_string, ls_result)
Return ''

end function

on nvo_md5.create
call super::create
TriggerEvent( this, "constructor" )
end on

on nvo_md5.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

