// ************************************************************************************************
// ************************************************************************************************
// **
// **  Title       : hdmi_tx_top.sv
// **  Design      : hdmi_tx
// **  Author      : Yanglyaev Ramil
// **
// ************************************************************************************************
// **
// **  Description : HDMI-TX 1.4 controller.
// **
// ************************************************************************************************
// **
// **  Change log  : 1.0 version - 07.07.2025, created file by Yanglyaev Ramil
// **
// ************************************************************************************************
// ************************************************************************************************

module hdmi_tx_top #(
    parameter VID_DATA_WIDTH  = 48, // Video data width in AXI-S interface
    parameter SND_DATA_WIDTH  = 48, // Sound data width in AXI-S interface

    parameter AXIL_ADDR_WIDTH = 32, // AXI-Lite address width
    parameter AXIL_DATA_WIDTH = 32, // AXI-Lite data width
)(

    // System channel
    input  wire                            sys_clk_i      , // system clok signal 
    input  wire                            sys_rstn_i     , // reset system (active low)

    // AXI-Stream : Video Data
    input  wire                            vd_tclk_i      , // Video clock signal
    input  wire [  VID_DATA_WIDTH-1:0]     vd_tdata_i     , // Video data signal
    input  wire                            vd_tvalid_i    , // Valid signal for video data packet
    output wire                            vd_tready_o    , // Ready signal for video data packet
    input  wire                            vd_tlast_i     , // Last data signal for video data packet
    input  wire [VID_DATA_WIDTH/8-1:0]     vd_tkeep_i     , // Mask for valid data bytes
    input  wire                            vd_tuser_i     , // User-defined signal

    // AXI-Stream : Audio Data
    input  wire                            ad_tclk_i      , // Audio clock signal
    input  wire [  SND_DATA_WIDTH-1:0]     ad_tdata_i     , // Audio data signal
    input  wire                            ad_tvalid_i    , // Valid signal for audio data packet
    output wire                            ad_tready_o    , // Ready signal for audio data packet
    input  wire                            ad_tlast_i     , // Last data signal for audio data packet
    input  wire [SND_DATA_WIDTH/8-1:0]     ad_tkeep_i     , // Mask for valid data bytes
    input  wire                            ad_tuser_i     , // User-defined signal
    
    // AXI-Lite Control Interface : System channel
    input  wire                            axil_clk_i     , // AXI-Lite clock signal
    input  wire                            axil_arstn_i   , // AXI-Lite asinc reset signal (active low)

    // AXI-Lite Control Interface : Write channel
    input  wire [   AXIL_ADDR_WIDTH-1 : 0] axil_awaddr_i  , // Write address
    input  wire                            axil_awvalid_i , // Write address valid signal
    output wire                            axil_awready_o , // Write address ready signal
    input  wire [   AXIL_DATA_WIDTH-1 : 0] axil_wdata_i   , // Write data
    input  wire                            axil_wvalid_i  , // Write data valid signal
    output wire                            axil_wready_o  , // Write data ready signal
    output wire [                   1 : 0] axil_bresp_o   , // Write response
    output wire                            axil_bvalid_o  , // Write response valid signal
    input  wire                            axil_bready_i  , // Write response ready signal

    // AXI-Lite Control Interface : Read channel
    input  wire [   AXIL_ADDR_WIDTH-1 : 0] axil_araddr_i  , // Read address
    input  wire                            axil_arvalid_i , // Read address valid signal
    output wire                            axil_arready_o , // Read address ready signal
    output wire [   AXIL_DATA_WIDTH-1 : 0] axil_rdata_o   , // Read data
    output wire [                   1 : 0] axil_rresp_o   , // Read response
    output wire                            axil_rvalid_o  , // Read data valid signal
    input  wire                            axil_rready_i  , // Read data ready signal

ARADDR — адрес чтения
ARVALID — адрес чтения валиден
ARREADY — готовность принять адрес чтения
RDATA — данные для чтения
RRESP — ответ на чтение
RVALID — данные для чтения валидны
RREADY — готовность принять данные

    // Interrupt device signal
    output wire                                                 interrupt_o  , // system interrupt
    // APB interface                                      
    input  wire                                                 penable_i    , // enable signal
    input  wire                                                 psel_i       , // select signal
    output wire                                                 pready_o     , // ready signal
    output wire                                                 pslverr_o    , // error signal  
    input  wire [ APB_ADDR_WIDTH-1 : 0]                         paddr_i      , // address signal
    input  wire                                                 pwrite_i     , // write signal  
    input  wire [ APB_DATA_WIDTH-1 : 0]                         pwdata_i     , // write data signal
    output wire [ APB_DATA_WIDTH-1 : 0]                         prdata_o     , // read data signal
    // Video interface Input DEBUG
    input  wire                                                 x_data_en_i    , // data enable
//    input  wire [ PIX_PER_CLC_IN-1 : 0][  VID_DATA_WIDTH-1 : 0] dv_0_i       , // video data ch G/Y  component
//    input  wire [ PIX_PER_CLC_IN-1 : 0][  VID_DATA_WIDTH-1 : 0] dv_1_i       , // video data ch R/Cr component
//    input  wire [ PIX_PER_CLC_IN-1 : 0][  VID_DATA_WIDTH-1 : 0] dv_2_i       , // video data ch B/Cb component
    input  wire [PIX_PER_CLC_IN-1:0][2:0][VID_DATA_WIDTH-1 : 0] x_data_vid_i   , //  video data ch R/Cr, B/Cb, G/Y, R/Cr, B/Cb, G/Y 
    input  wire                                                 x_field_i      , // field signal
    input  wire                                                 x_h_sync_i     , // horizontal synchronization signal
    input  wire                                                 x_v_sync_i     , // vertical synchronization signal
    // Video interface Input
    input  wire                                                 data_en_i    , // data enable
//    input  wire [ PIX_PER_CLC_IN-1 : 0][  VID_DATA_WIDTH-1 : 0] dv_0_i       , // video data ch G/Y  component
//    input  wire [ PIX_PER_CLC_IN-1 : 0][  VID_DATA_WIDTH-1 : 0] dv_1_i       , // video data ch R/Cr component
//    input  wire [ PIX_PER_CLC_IN-1 : 0][  VID_DATA_WIDTH-1 : 0] dv_2_i       , // video data ch B/Cb component
    input  wire [PIX_PER_CLC_IN-1:0][2:0][VID_DATA_WIDTH-1 : 0] data_vid_i   , //  video data ch R/Cr, B/Cb, G/Y, R/Cr, B/Cb, G/Y 
    input  wire                                                 field_i      , // field signal
    input  wire                                                 h_sync_i     , // horizontal synchronization signal
    input  wire                                                 v_sync_i     , // vertical synchronization signal
    // SPDIF interface
    input  wire                                                 spdif_i      , // spdif serial line
    // I2S interface
    input  wire                                                 ws_i         , // word select
    input  wire                                                 sd_0_i       , // ch0 serial data
    input  wire                                                 sd_1_i       , // ch1 serial data
    input  wire                                                 sd_2_i       , // ch2 serial data
    input  wire                                                 sd_3_i       , // ch3 serial data
    // HPD signal (Hot Plug/Unplug Detection)
    input  wire                                                 hpd_i        , // HPD signal (Hot Plug/Unplug Detection)
    output wire                                                 hdmi_pwr_o   , // HDMI_PWR / Power Management
    // T.M.D.S. Output
    output wire                                                 tmds_clk_o   , // TMDS clock
    output reg  [PIX_PER_CLC_OUT-1  : 0][TMDS_DATA_WIDTH-1 : 0] tmds_ch_0_o  , // BLU
    output reg  [PIX_PER_CLC_OUT-1  : 0][TMDS_DATA_WIDTH-1 : 0] tmds_ch_1_o  , // GRN
    output reg  [PIX_PER_CLC_OUT-1  : 0][TMDS_DATA_WIDTH-1 : 0] tmds_ch_2_o  , // RED
    output reg                                                  tmds_valid_o   // Valid pixel
);

// ****************************************************************************
// Parameter
// ****************************************************************************
    localparam PIX_PER_ONE_CLC = PIX_PER_CLC_IN ;

// ****************************************************************************
// Wire/reg declarations
// ****************************************************************************
    wire [PIX_PER_CLC_IN-1 : 0][TMDS_DATA_WIDTH-1 : 0] tmds_ch_0  ;
    wire [PIX_PER_CLC_IN-1 : 0][TMDS_DATA_WIDTH-1 : 0] tmds_ch_1  ;
    wire [PIX_PER_CLC_IN-1 : 0][TMDS_DATA_WIDTH-1 : 0] tmds_ch_2  ;
    wire                                               tmds_valid ;

    wire [PIX_PER_CLC_IN-1 : 0][VID_DATA_WIDTH-1 : 0] dv_0 ;
    wire [PIX_PER_CLC_IN-1 : 0][VID_DATA_WIDTH-1 : 0] dv_1 ;
    wire [PIX_PER_CLC_IN-1 : 0][VID_DATA_WIDTH-1 : 0] dv_2 ;

    // DEBUG
    reg                                                 data_en  ;
    reg [PIX_PER_CLC_IN-1:0][2:0][VID_DATA_WIDTH-1 : 0] data_vid ;
    reg                                                 field    ;
    reg                                                 h_sync   ;
    reg                                                 v_sync   ;

// *******************************************************************
// Modules
// *******************************************************************

    always @(posedge pix_clk_i) begin
        if (debug_o[0]) begin
            data_en  <= data_en_i    ;
            data_vid <= data_vid_i   ;
            field    <= field_i      ;
            h_sync   <= h_sync_i     ;
            v_sync   <= v_sync_i     ;
        end else begin
            data_en  <= x_data_en_i  ;
            data_vid <= x_data_vid_i ;
            field    <= x_field_i    ;
            h_sync   <= x_h_sync_i   ;
            v_sync   <= x_v_sync_i   ;
        end
    end

    // assign data_en  = debug_o[0] ? data_en_i  : x_data_en_i  ;
    // assign data_vid = debug_o[0] ? data_vid_i : x_data_vid_i ;
    // assign field    = debug_o[0] ? field_i    : x_field_i    ;
    // assign h_sync   = debug_o[0] ? h_sync_i   : x_h_sync_i   ;
    // assign v_sync   = debug_o[0] ? v_sync_i   : x_v_sync_i   ;
        

// Slice data video stream
    for (genvar i = 0; i < PIX_PER_CLC_IN; i++) begin
        assign {dv_2[i], dv_1[i], dv_0[i]} = {data_vid[i][1], data_vid[i][2], data_vid[i][0]} ; // BBRRGG <= RBGRBG
    end

// HDMI_TX Core
    hdmi_tx_core #(
        .PIX_PER_ONE_CLC ( PIX_PER_ONE_CLC ),
        .TRIG_NUM        ( TRIG_NUM        ),
        .APB_DATA_WIDTH  ( APB_DATA_WIDTH  ),
        .APB_ADDR_WIDTH  ( APB_ADDR_WIDTH  ),
        .VID_DATA_WIDTH  ( VID_DATA_WIDTH  ),
        .TMDS_DATA_WIDTH ( TMDS_DATA_WIDTH )
    ) u_hdmi_tx_core (
        // DEBUG
        .debug_o      ( debug_o           ),
        // System channel
        .sys_clk_i    ( sys_clk_i         ),
        .sys_rstn_i   ( sys_rstn_i        ),
        .apb_clk_i    ( apb_clk_i         ),
        .apb_rstn_i   ( apb_rstn_i        ),
        .pix_clk_i    ( pix_clk_i         ),
        .sck_i        ( sck_i             ),
        .pix_rstn_o   ( pix_rstn          ),
        // DFT channel
        .scan_en_i    ( scan_en_i         ),
        // Interrupt device signal
        .interrupt_o  ( interrupt_o       ),
        // APB interface  
        .penable_i    ( penable_i         ),
        .psel_i       ( psel_i            ),
        .pready_o     ( pready_o          ),
        .pslverr_o    ( pslverr_o         ),
        .paddr_i      ( paddr_i           ),
        .pwrite_i     ( pwrite_i          ),
        .pwdata_i     ( pwdata_i          ),
        .prdata_o     ( prdata_o          ),
        // Video interface
        .data_en_i    ( data_en           ),
        .dv_0_i       ( dv_0              ), // G/Y 
        .dv_1_i       ( dv_1              ), // R/Cr
        .dv_2_i       ( dv_2              ), // B/Cb
        .field_i      ( field             ),
        .h_sync_i     ( h_sync            ),
        .v_sync_i     ( v_sync            ),
        // SPDIF interface
        .spdif_i      ( spdif_i           ),
        // I2S interface
        .ws_i         ( ws_i              ),
        .sd_0_i       ( sd_0_i            ),
        .sd_1_i       ( sd_1_i            ),
        .sd_2_i       ( sd_2_i            ),
        .sd_3_i       ( sd_3_i            ),
        // HPD signal (Hot Plug/Unplug Detection)
        .hpd_i        ( hpd_i             ),
        .hdmi_pwr_o   ( hdmi_pwr_o        ),
        // T.M.D.S. Input
        .tmds_ch_0_o  ( tmds_ch_0         ), // BLU
        .tmds_ch_1_o  ( tmds_ch_1         ), // GRN
        .tmds_ch_2_o  ( tmds_ch_2         ), // RED
        .tmds_valid_o ( tmds_valid        )
    );

// *******************************************************************
// Change depending on the number of input and output requirements
    if (((PIX_PER_CLC_IN == 1) && (PIX_PER_CLC_OUT == 1)) | 
        ((PIX_PER_CLC_IN == 2) && (PIX_PER_CLC_OUT == 2))) begin:u_hdmi_tx_inNpix_outNpix

        always @(posedge pix_clk_i) begin
            tmds_ch_0_o  <= tmds_ch_0  ;
            tmds_ch_1_o  <= tmds_ch_1  ;
            tmds_ch_2_o  <= tmds_ch_2  ;
            tmds_valid_o <= tmds_valid ;
        end

        // assign tmds_ch_0_o = tmds_ch_0 ;
        // assign tmds_ch_1_o = tmds_ch_1 ;
        // assign tmds_ch_2_o = tmds_ch_2 ;
        // assign tmds_valid_o = tmds_valid ;
        assign tmds_clk_o = pix_clk_i ;

    end
    else if ((PIX_PER_CLC_IN == 1) && (PIX_PER_CLC_OUT == 2)) begin:u_hdmi_tx_in1pix_out2pix
    // *******************************************************************
    // Parameter
        localparam AFIFO_DATA_WIDTH = 3*TMDS_DATA_WIDTH*PIX_PER_CLC_OUT ;
        localparam AFIFO_DEPTH      =  4 ;
        localparam DFACT            =  2 ;
    
    // *******************************************************************
    // Wire/reg declarations
        // hdmi_core to/from Deserializer

        // Deserializer to/from AFIFO
        wire [PIX_PER_CLC_OUT-1 : 0][TMDS_DATA_WIDTH-1 : 0] deser_afifo_data_ch0 ;
        wire [PIX_PER_CLC_OUT-1 : 0][TMDS_DATA_WIDTH-1 : 0] deser_afifo_data_ch1 ;
        wire [PIX_PER_CLC_OUT-1 : 0][TMDS_DATA_WIDTH-1 : 0] deser_afifo_data_ch2 ;
        wire [PIX_PER_CLC_OUT-1 : 0][               31 : 0] deser_afifo_data     ;
        wire                                                deser_afifo_valid    ;
        wire                                                deser_afifo_ready    ;

        // Ckdiv to/from AFIFO
        wire tmds_clk ;

    // *******************************************************************
    // Module body
        // Data bytes DeSerializer
        gp_deserializer_byte #(
            .IN_DATA_WIDTH      ( 32 ),
            .IN_WORD_SIZE_WIDTH (  3 ),
            .OUT_DATA_WIDTH     ( 64 )
        ) u_gp_deserializer_byte (
            // System channel
            .clk_i       ( pix_clk_i     ),
            .rstn_i      ( pix_rstn      ),
            // Control interface
            .word_size_i ( 3'd4          ),
            // Receiver data interface
            .rx_ready_o  (               ),
            .rx_valid_i  ( tmds_valid    ),
            .rx_data_i   ( {2'h0, 
                            tmds_ch_2, 
                            tmds_ch_1, 
                            tmds_ch_0}   ),
            // Transmitter data interface 
            .tx_ready_i  ( deser_afifo_ready ),
            .tx_valid_o  ( deser_afifo_valid ),
            .tx_data_o   ( deser_afifo_data  ) 
        );
    
        for (genvar num_pix = 0; num_pix < 2; num_pix++ ) begin:order_changer
            assign {deser_afifo_data_ch2[num_pix], deser_afifo_data_ch1[num_pix], deser_afifo_data_ch0[num_pix]} = deser_afifo_data[num_pix][0 +: 3*TMDS_DATA_WIDTH] ;
        end

        // AFIFO buf
        gp_afifo_buf #(
            .BUF_DEPTH  ( AFIFO_DEPTH      ), // buffer depth. power of 2
            .DATA_WIDTH ( AFIFO_DATA_WIDTH )  // input data bus width
        ) u_gp_afifo_buf (
            // Source channel
            .src_clk_i   ( pix_clk_i              ),  // write clock signal
            .src_rstn_i  ( pix_rstn               ),  // write reset signal - active low
            .src_data_i  ( {deser_afifo_data_ch2, 
                            deser_afifo_data_ch1, 
                            deser_afifo_data_ch0 } ),  // write data bus
            .src_valid_i ( deser_afifo_valid       ),  // write valid signal - active high
            .src_ready_o ( deser_afifo_ready       ),  // write ready signal - active high
            // Destination channel
            .dst_clk_i   ( tmds_clk                ),  // read clock signal
            .dst_rstn_i  ( pix_rstn                ),  // read reset signal - active low
            .dst_data_o  ( {tmds_ch_2_o, 
                            tmds_ch_1_o, 
                            tmds_ch_0_o}           ),  // read data bus
            .dst_valid_o ( tmds_valid_o            ),  // read valid signal - active high
            .dst_ready_i ( 1'b1                    )   // read ready signal - active high
        );

        // Clock frequency divider
        hdmi_tx_ckdiv #(
            .DFACT   ( DFACT ),
            .BYPEN   ( 0     ),
            .BYPSYNC ( 0     ),
            .DFTEN   ( 0     )
        ) u_hdmi_tx_ckdiv (
            // System channel
            .rstn_i    ( pix_rstn   ),
            // Ctrl channel
            .scan_en_i ( 1'b1       ),
            .bypass_i  ( 1'b1       ),
            // Clock channel
            .clk_i     ( pix_clk_i  ),   
            .dclk_o    ( tmds_clk   ),  
            .dclken_o  (            )
        );

        assign tmds_clk_o = tmds_clk ;
    end

// *******************************************************************
endmodule // hdmi_tx_top