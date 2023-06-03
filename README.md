I wanted to learn the openlane flow and was working on another tool that linked ai with verilog files, so i decided to give it a shot. With having 0 knowladge on how to do any of this, i tought ai would be a great at holding my hand. 

I didnt want to start with something totally useless, so i decided to do a vga controller. A vga contoller is a circuit which just does the timings for the display, the image is encoded into that signal. 
[here is a digikey article](https://forum.digikey.com/t/vga-controller-vhdl/12794). This implementation is a bit silly, but thats the whole point.

 

[GPT4 logs](https://chat.openai.com/share/8d51e813-800a-418d-8181-f506546945fc)


to connect to the controller, just use the gpio's. it should provide the neccessary signals in theory
