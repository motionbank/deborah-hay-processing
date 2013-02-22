void initDatabase ()
{
    db = new SQLite( this, sketchPath("../db.sqlite") );
    db.connect();
    addSQLiteHammingDistance();
}

