void keyPressed ()
{
    switch ( key )
    {
        case '1':
            viewMode = 0;
            break;
        case '2':
            viewMode = 1;
            break;
        case '3':
            viewMode = 2;
            break;
        case '4':
            viewMode = 3;
            break;
        case 'p':
            savePDF = true;
            break;
    }
}
