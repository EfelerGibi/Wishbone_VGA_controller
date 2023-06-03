module Wishbone_VGA_controller (
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif
    // Wishbone bus inputs
    input  wire clk,
    input  wire rst,
    input  wire cyc,
    input  wire stb,
    input  wire we,     // Write Enable
    input  wire [31:0] adr,
    input  wire [31:0] dat,
    // Wishbone bus outputs
    output reg [31:0] dout,
	 output reg ack,
	 //vga
	 output wire n_blank,
    output wire n_sync,
    output wire h_sync,
    output wire v_sync,
    output wire display_enable,
    output wire [11:0] row,
	output wire [11:0] column
	 
);

    // VGA controller outputs


    // Instantiate VGA controller
    AI_Vga vga_controller (
        .pixel_clk(clk),
        .async_reset(!rst),
        .n_blank(n_blank),
        .n_sync(n_sync),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .display_enable(display_enable),
        .row(row),
        .column(column)
    );

    // Wishbone bus operation
    always @(posedge clk) begin
        if (rst) begin
            dout <= 0;
				ack <= 0;
        end
        else if (cyc && stb) begin
                // Combine the VGA controller signals into one 32-bit output
                dout <= {n_blank, n_sync, h_sync, v_sync, display_enable,row, column, 4'b0};
				ack <= 1;
        end
		  else begin ack <=0; 
		  end
    end

endmodule



module AI_Vga(
    input pixel_clk, 
    input async_reset,
    output n_blank, 
    output n_sync, 
    output reg h_sync, 
    output reg v_sync, 
    output reg display_enable,
    output reg [11:0] row, 
    output reg [11:0] column
);

// Parameters for 640x480 @60Hz
parameter h_visible = 640, v_visible = 480,
          h_sync_p = 16, v_sync_p = 2,
          h_back_porch = 48, v_back_porch = 33,
          h_front_porch = 96, v_front_porch = 10,
          h_total = h_visible + h_sync_p + h_back_porch + h_front_porch,
          v_total = v_visible + v_sync_p + v_back_porch + v_front_porch;

reg [11:0] h_counter = 0, v_counter = 0;

// Reset functionality
always @(posedge pixel_clk or negedge async_reset)
    if (!async_reset) begin
        h_counter <= 0;
        v_counter <= 0;
    end else begin
        h_counter <= (h_counter + 1) % h_total;
        if (h_counter == h_total - 1)
            v_counter <= (v_counter + 1) % v_total;
    end

// Sync signals
always @(posedge pixel_clk)
    h_sync <= (h_counter < h_visible + h_sync_p);

always @(posedge pixel_clk)
    v_sync <= (v_counter < v_visible + v_sync_p);

// Blank and sync signals
assign n_blank = (h_counter < h_visible) && (v_counter < v_visible);
assign n_sync = h_sync && v_sync;

// Display enable signal
assign display_enable = n_blank && !n_sync;

// Column and row
always @(posedge pixel_clk)
    column <= (display_enable) ? h_counter : 12'b0;

always @(posedge pixel_clk)
    row <= (display_enable) ? v_counter : 12'b0;

endmodule


