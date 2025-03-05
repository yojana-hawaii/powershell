
use master
go

--USER INPUT 
declare @dbName nvarchar(50) = 'DaHubInventory';
declare @dataDirectory nvarchar(100) = 'E:\Data\';
declare @logDirectory nvarchar(100) = 'F:\Logs\';
declare @dbCompatibility nvarchar(100) = '130';
declare @user nvarchar(100) = 'username';



-- DO NOT TOUCH THE REST > drop database, create new database with USER INPUT name, location and compatibility
declare @dbNameQuote nvarchar(52) = QUOTENAME(@dbname);
declare @dbNameSingleQuote nvarchar(52) = '''' + @dbName + '''';
declare @dbNameLogSingleQuote nvarchar(52) = '''' + @dbName + '_log''';
declare @userQuote varchar(100) = quotename(@user);

declare @useMaster nvarchar(20) = 'USE [Master];'
declare @useDaHubInventory nvarchar(20) = 'USE ' + @dbNameQuote + ';';



declare @dataPath nvarchar(150) = '''' + @dataDirectory + @dbName +  '.mdf' + '''';
declare @logPath nvarchar(150) = ''''+ @logDirectory + @dbName + '.ldf' + '''';
declare @master nvarchar(100) = quotename('master')

declare @q1 nvarchar(100) = ' if not exists ( select * from sys.databases where name=';
declare @q2 nvarchar(100) = ') begin CREATE DATABASE ';
declare @q3 nvarchar(100) = ' CONTAINMENT = NONE ON  PRIMARY ( NAME = ';
declare @q4 nvarchar(100) = ', FILENAME = ';
declare @q5 nvarchar(100) = ' , SIZE = 1024, MAXSIZE = 10240MB, FILEGROWTH = 10% ) LOG ON ( NAME = '
declare @q6 nvarchar(100) = ',FILENAME ='
declare @q7 nvarchar(100) = ', SIZE =  5,MAXSIZE = 2048MB , FILEGROWTH = 5) END'


declare @dropDatabase nvarchar(100) = 'drop database if exists ' + @dbNameQuote + ';';
declare @createDatabase nvarchar(max) =  @q1 + @dbNameSingleQuote + @q2 + @dbNameQuote + @q3 + @dbNameSingleQuote +
						@q4 + @dataPath + @q5 + @dbNameLogSingleQuote + @q6 + @logPath + @q7 + ';';

declare @compatibility nvarchar(100) = 'ALTER DATABASE ' + @dbNameQuote + ' SET COMPATIBILITY_LEVEL = ' + @dbCompatibility + ';'
declare @saAuth nvarchar(100) = 'ALTER AUTHORIZATION ON DATABASE::' + @dbNameQuote + 'to sa;'
declare @readWrite nvarchar(100) = 'ALTER DATABASE' + @dbNameQuote + ' SET  READ_WRITE ;'

declare @read nvarchar(100) = 'db_datareader'
declare @write nvarchar(100) = 'db_datawriter'


if (@dbName like '%[^0-9A-Z]%')
	RAISERROR('Invalid character in database name, %s', 16,1, @dbName);

else 
	begin
		execute sp_executesql @useMaster;
		execute sp_executesql @dropDatabase;
		execute sp_executesql @createDatabase;
		execute sp_executesql @compatibility;
		execute sp_executesql @readWrite;
		execute sp_executesql @saAuth;
	end;
	


use DaHubInventory

if not exists(select * from sys.database_principals where name = @user)
begin
	CREATE USER @userQuote FOR LOGIN @userQuote WITH DEFAULT_SCHEMA=[dbo]
	ALTER ROLE [db_owner] ADD MEMBER @userQuote
end


