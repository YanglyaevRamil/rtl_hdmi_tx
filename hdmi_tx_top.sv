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
    parameter AUD_DATA_WIDTH  = 48, // Sound data width in AXI-S interface

    parameter AXIL_ADDR_WIDTH = 32, // AXI-Lite address width
    parameter AXIL_DATA_WIDTH = 32, // AXI-Lite data width

    parameter TMDS_DATA_WIDTH = 10, // TMDS bus width, does not change

    parameter PIX_PER_CLK     =  2  // Number of pixels per clock at input
)(

    // System channel
    input  wire                                               sys_clk_i      , // system clok signal 
    input  wire                                               sys_rstn_i     , // reset system (active low)

    // AXI-Stream: Video Data
    input  wire                                               vid_tclk_i     , // Video clock signal
    input  wire [PIX_PER_CLK-1 : 0][    VID_DATA_WIDTH-1 : 0] vid_tdata_i    , // Video data signal
    input  wire                                               vid_tvalid_i   , // Valid signal for video data packet
    output wire                                               vid_tready_o   , // Ready signal for video data packet
    input  wire                                               vid_tlast_i    , // Last data signal for video data packet
    input  wire                     [ VID_DATA_WIDTH/8-1 : 0] vid_tkeep_i    , // Mask for valid data bytes
    input  wire                                               vid_tuser_i    , // User-defined signal

    // AXI-Stream: Audio Data
    input  wire                                               aud_tclk_i     , // Audio clock signal
    input  wire                     [   AUD_DATA_WIDTH-1 : 0] aud_tdata_i    , // Audio data signal
    input  wire                                               aud_tvalid_i   , // Valid signal for audio data packet
    output wire                                               aud_tready_o   , // Ready signal for audio data packet
    input  wire                                               aud_tlast_i    , // Last data signal for audio data packet
    input  wire                     [ AUD_DATA_WIDTH/8-1 : 0] aud_tkeep_i    , // Mask for valid data bytes
    input  wire                                               aud_tuser_i    , // User-defined signal
    
    // AXI-Lite Control Interface : System channel
    input  wire                                               axil_clk_i     , // AXI-Lite clock signal
    input  wire                                               axil_arstn_i   , // AXI-Lite asinc reset signal (active low)
    // AXI-Lite Control Interface : Write address channel
    input  wire                                               axil_awvalid_i , // Write address valid signal
    output wire                                               axil_awready_o , // Write address ready signal
    input  wire                     [  AXIL_ADDR_WIDTH-1 : 0] axil_awaddr_i  , // Write address
    // AXI-Lite Control Interface : Write data channel
    input  wire                                               axil_wvalid_i  , // Write data valid signal
    output wire                                               axil_wready_o  , // Write data ready signal
    input  wire                     [  AXIL_DATA_WIDTH-1 : 0] axil_wdata_i   , // Write data
    input  wire                     [AXIL_DATA_WIDTH/8-1 : 0] axil_wstrb_i   , // Write data strobes
    // AXI-Lite Control Interface : Write response channel
    output wire                                               axil_bvalid_o  , // Write response valid signal
    input  wire                                               axil_bready_i  , // Write response ready signal
    output wire                     [                  1 : 0] axil_bresp_o   , // Write response
    // AXI-Lite Control Interface : Read address channel
    input  wire                                               axil_arvalid_i , // Read address valid signal
    output wire                                               axil_arready_o , // Read address ready signal
    input  wire                     [  AXIL_ADDR_WIDTH-1 : 0] axil_araddr_i  , // Read address
    // AXI-Lite Control Interface : Read data channel
    output wire                                               axil_rvalid_o  , // Read data valid signal
    input  wire                                               axil_rready_i  , // Read data ready signal
    output wire                     [  AXIL_DATA_WIDTH-1 : 0] axil_rdata_o   , // Read data
    output wire                     [                  1 : 0] axil_rresp_o   , // Read response

    // AXI-Stream : TMDS System channel
    output wire                                               tmds_aclk_o       , // TMDS clock signal
    // AXI-Stream : TMDS Channel 0 of TMDS lane N (0 < N <= PIX_PER_CLK-1)
    output wire                                               tmds_tvalid_ch0_o , // Valid signal for TMDS data packet
    input  wire                                               tmds_tready_ch0_i , // Ready signal for TMDS data packet
    output wire [PIX_PER_CLK-1  : 0][  TMDS_DATA_WIDTH-1 : 0] tmds_tdata_ch0_o  , // TMDS data channel 0, B | Cb
    // AXI-Stream : TMDS Channel 1 of TMDS lane N (0 < N <= PIX_PER_CLK-1)
    output wire                                               tmds_tvalid_ch1_o , // Valid signal for TMDS data packet
    input  wire                                               tmds_tready_ch1_i , // Ready signal for TMDS data packet
    output wire [PIX_PER_CLK-1  : 0][  TMDS_DATA_WIDTH-1 : 0] tmds_tdata_ch1_o  , // TMDS data channel 1, G | Y
    // AXI-Stream : TMDS Channel 2 of TMDS lane N (0 < N <= PIX_PER_CLK-1)
    output wire                                               tmds_tvalid_ch2_o , // Valid signal for TMDS data packet
    input  wire                                               tmds_tready_ch2_i , // Ready signal for TMDS data packet
    output wire [PIX_PER_CLK-1  : 0][  TMDS_DATA_WIDTH-1 : 0] tmds_tdata_ch2_o  , // TMDS data channel 2, R | Cr

    // Interrupt device signal
    output wire                                               interrupt_o         // system interrupt
);

// ****************************************************************************
// Parameter
// ****************************************************************************

// ****************************************************************************
// Wire/reg declarations
// ****************************************************************************

// *******************************************************************
// Modules
// *******************************************************************
    axi_lite_slave (
        .
    ) u_hdmi_tx_axi_lite_slave (
        .(),
    );

    hdmi_tx_reg_if (

    ) u_hdmi_tx_reg_if (

    );



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