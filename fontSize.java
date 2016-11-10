enum font_size 
{
   small(16, 0), medium(32, 1), large(48, 2);
   
   int size;
   int index;
   font_size(int size, int index)
   {
     this.size = size;
     this.index = index;
   }
}