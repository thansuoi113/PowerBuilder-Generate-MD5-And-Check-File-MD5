$PBExportHeader$pbmd5.sra
$PBExportComments$Generated Application Object
forward
global type pbmd5 from application
end type
global transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global type pbmd5 from application
string appname = "pbmd5"
end type
global pbmd5 pbmd5

on pbmd5.create
appname="pbmd5"
message=create message
sqlca=create transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on pbmd5.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;open(w_main)
end event

