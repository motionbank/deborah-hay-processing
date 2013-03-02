void initDatabase ()
{
    db = new SQLite( this, sketchPath(dbPath + "/" + dbFile) );
    db.connect();
    addSQLiteDistanceFunctions();
}

