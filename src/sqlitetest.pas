program SqliteTest;
{$SMARTLINK ON}
{$PACKRECORDS 4}
{$MODE objfpc}

uses
 db, sqlite3ds, SysUtils;

var
 dsTutorial: TSQLite3Dataset;
 mSql: string;
  (* TFields declarations
    You can use Field[n].AsString but its slower *)
 mId: TIntegerField;
 mFirstName: TStringField;
 mLastName: TStringField;
 mBornDate: TDateTimeField;

begin
 dsTutorial := TSqlite3Dataset.Create(nil);

  try
 with dsTutorial do
 begin
   FileName := 'tutorial.db';
   TableName := 'customers';
   PrimaryKey := 'Id';

   (* Define the Insert skleton -uptate and delete works the same way-*)
   mSql := 'insert into customers(firstname, lastname, borndate) ' +
     'values(''%s'', ''%s'', %f)';

   (* Non transactional method *)
   (* Insert first customer *)
   Sql := Format(mSql, ['Leonardo', 'Ramé', Now]);
   ExecSql;

   (* Insert second customer *)
   Sql := Format(mSql, ['Michael', 'Stratten', Now]);
   ExecSql;

   (* Transactional method *)
   (* I don't really know why I must populate the TFields using a Select,
       if you know an elegant way to accomplish this, please tell me. *)
   Sql := 'select Id, FirstName, LastName, BornDate from customers limit 1';
   Open;

   (* Assign TFields *)
   mId := TIntegerField(Fields[0]);
   mFirstName := TStringField(Fields[1]);
   mLastName := TStringField(Fields[2]);
   mBornDate := TDateTimeField(Fields[3]);

   (* Append, Edit or Insert for the first field *);
   Append;
   mFirstName.Value := 'Juan';
   mLastName.Value := 'Pérez';
   mBornDate.Value := Now;
   Post;

   (* Append, Edit or Insert for the second field *);
   Insert;
   mFirstName.Value := 'Johan';
   mLastName.Value := 'Arndth';
   mBornDate.Value := Now;
   Post;

    (* This commits the data to the db. *)
   ApplyUpdates;

   (* Now, select all fields *)
   Close;
   Sql := 'select Id, FirstName, LastName, BornDate from customers';
   Open;

   (* To go to the first record of the DataSet, use First.
       This isn't usefull here since Open points to the first record,
       but you'll need in your projects so I keep it in the example. *)
   First;
   while not Eof do
   begin
     mId := TIntegerField(Fields[0]);
     mFirstName := TStringField(Fields[1]);
     mLastName := TStringField(Fields[2]);
     mBornDate := TDateTimeField(Fields[3]);

     writeln (IntToStr(mId.Value) + ' - ' + mFirstName.Value + ', ' +
       mLastName.Value + ' - ' + DateToStr(mBornDate.Value));
     (* Move to the next record *)
     Next;
   end;
 end;
 finally
   dsTutorial.Free;
  end;

end.
