public static void copyFile(File in, File out) 
{
    FileInputStream fis = null;
    FileOutputStream fos = null;

    try {
        fis  = new FileInputStream(in);
        fos = new FileOutputStream(out);
    } 
    catch ( Exception e ) {
        e.printStackTrace();
    }

    try {
        byte[] buf = new byte[1024];
        int i = 0;
        while ( (i = fis.read (buf)) != -1) {
            fos.write(buf, 0, i);
        }
    } 
    catch (Exception e) {
        e.printStackTrace();
    }

    try {
        if (fis != null) fis.close();
        if (fos != null) fos.close();
    } 
    catch ( Exception e ) {
        e.printStackTrace();
    }
}

public void copyDirectory ( File sourceLocation, File targetLocation )
{
    try {
        if (sourceLocation.isDirectory()) 
        {
            if (!targetLocation.exists()) 
            {
                targetLocation.mkdir();
            }

            String[] children = sourceLocation.list();
            for (int i=0; i<children.length; i++) 
            {
                copyDirectory(new File(sourceLocation, children[i]), 
                new File(targetLocation, children[i]));
            }
        } 
        else 
        {

            InputStream in = new FileInputStream(sourceLocation);
            OutputStream out = new FileOutputStream(targetLocation);

            // Copy the bits from instream to outstream
            byte[] buf = new byte[1024];
            int len;
            while ( (len = in.read (buf)) > 0) 
            {
                out.write(buf, 0, len);
            }
            in.close();
            out.close();
        }
    } 
    catch ( Exception e ) {
        e.printStackTrace();
    }
}

