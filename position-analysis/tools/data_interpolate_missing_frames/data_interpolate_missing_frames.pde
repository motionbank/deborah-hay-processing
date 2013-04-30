/**
 *    Motion Bank research, http://motionbank.org/
 *
 *    Processing 2.0
 *    created: fjenett 20130314
 */
 
 import java.awt.dnd.*; 
 import java.awt.datatransfer.*; 

 void setup ()
 {
     size( 200, 200 );
     
     DropTarget dt = new DropTarget( this, new DropTargetListener() { 
        public void dragEnter(DropTargetDragEvent event) { 
            event.acceptDrag(DnDConstants.ACTION_COPY); 
        } 
    
        public void dragExit(DropTargetEvent event) { 
        } 
    
        public void dragOver(DropTargetDragEvent event) { 
            event.acceptDrag(DnDConstants.ACTION_COPY); 
        } 
    
        public void dropActionChanged(DropTargetDragEvent event) { 
        } 
    
        public void drop(DropTargetDropEvent event) { 
            event.acceptDrop(DnDConstants.ACTION_COPY); 
    
            Transferable transferable = event.getTransferable(); 
            DataFlavor flavors[] = transferable.getTransferDataFlavors(); 
            int successful = 0; 
    
            for (int i = 0; i < flavors.length; i++) 
            { 
                try { 
                    Object stuff = transferable.getTransferData(flavors[i]); 
                    if (!(stuff instanceof java.util.List)) continue; 
                    java.util.List list = (java.util.List) stuff; 
    
                    for (int j = 0; j < list.size(); j++) { 
                        Object item = list.get(j); 
                        if (item instanceof File) { 
                            File file = (File) item; 
                            
                            String fileName = file.getName();
                            if ( fileName.endsWith( ".txt" ) )
                            {
                                println( "Processing: " + fileName );
                                interpolateValues( file.getAbsolutePath() );
                            }
                        } 
                    } 
    
                }  
                catch (Exception e) { 
                    e.printStackTrace(); 
                } 
            } 
        } 
     });
 }
 
 void interpolateValues ( String file )
 {
     String[] lines = loadStrings( file );
     String[] linesOut = new String[lines.length];
     int lineNum = 0;
     int lastNum = -1;
     int[] valsLast = null;
     
     for ( int i = 0; i< lines.length; i++ )
     {
         int[] vals = int( split( lines[i], " " ) );
         
         if ( lastNum == vals[0] ) continue; // doubled? why?
         
         // catch up if 
         if ( vals[0] > lineNum )
         {
             int iFrom = lineNum;
             for ( int i3 = lineNum, d = vals[0]-lineNum; i3 < vals[0]; i3++ )
             {
                 if ( i3 >= linesOut.length )
                 {
                     linesOut = expand( linesOut ); // doubles it's length
                 }
                 
                 if ( valsLast == null )
                 {
                     linesOut[i3] = vals[1] + " " + vals[2];
                 }
                 else
                 {
                     linesOut[i3] = (int)map( i3, lineNum, vals[0], valsLast[1], vals[1] ) + " " + (int)map( i3, lineNum, vals[0], valsLast[2], vals[2] );
                 }
                 
                 lineNum++;
             }
             println( "fixed: " + iFrom + " -> " + vals[0] );
         }
         else if ( vals[0] < lineNum )
         {
             // ignore, this can't be
             continue;
         }
         
         if ( lineNum >= linesOut.length )
         {
             linesOut = expand( linesOut ); // doubles it's length
         }
         
         linesOut[lineNum] = vals[1] + " " + vals[2];
         lineNum++;
         
         lastNum = vals[0];
         valsLast = vals;
     }
     
     linesOut = expand( linesOut, lineNum-1 );
     saveStrings( file.replace(".txt","_FIXED.txt"), linesOut );
 }
 
 /*
 File d = new File("/Volumes/Verytim/2011_FIGD_April_Results/Ros/Ros_D01T01_withBackgroundAdjustment_Corrected/");
     String[] files = d.list();
     for ( String s : files )
     {
         if ( !s.toLowerCase().endsWith( ".txt" ) || s.toLowerCase().indexOf("_fixed") != -1 || s.toLowerCase().indexOf("_concat") != -1 ) continue;
         interpolateValues( d.getAbsolutePath() + "/" + s );
     }
 */
