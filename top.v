`include "dport.vh"

module top(
	input wire [1:0] refclk,
	output wire [3:0] tx,
	inout wire auxp,
	inout wire auxn,
	output wire debug,
	output wire debug2
);

	wire gp0_awvalid;
	wire gp0_awready;
	wire [1:0] gp0_awburst, gp0_awlock;
	wire [2:0] gp0_awsize, gp0_awprot;
	wire [3:0] gp0_awlen, gp0_awcache, gp0_awqos;
	wire [11:0] gp0_awid;
	wire [31:0] gp0_awaddr;

	wire gp0_arvalid;
	wire gp0_arready;
	wire [1:0] gp0_arburst, gp0_arlock;
	wire [2:0] gp0_arsize, gp0_arprot;
	wire [3:0] gp0_arlen, gp0_arcache, gp0_arqos;
	wire [11:0] gp0_arid;
	wire [31:0] gp0_araddr;

	wire gp0_wvalid, gp0_wlast;
	wire gp0_wready;
	wire [3:0] gp0_wstrb;
	wire [11:0] gp0_wid;
	wire [31:0] gp0_wdata;

	wire gp0_bvalid;
	wire gp0_bready;
	wire [1:0] gp0_bresp;
	wire [11:0] gp0_bid;

	wire gp0_rvalid;
	wire gp0_rready;
	wire [1:0] gp0_rresp;
	wire gp0_rlast;
	wire [11:0] gp0_rid;
	wire [31:0] gp0_rdata;

	wire [31:0] armaddr;
	wire [31:0] armrdata, armwdata;
	wire [3:0] armwstrb;
	wire armwr, armreq;
	wire armack, armerr;
	
	wire [19:0] auxaddr;
	wire [7:0] auxrdata, auxwdata;
	wire auxreq, auxack, auxwr, auxerr;
	wire auxi, auxo, auxd;
	
	wire [15:0] debugaddr;
	wire [31:0] debugrdata;
	wire debugreq, debugack;
	
	wire dpclk, fifoempty, fiforden, dphstart, dpvstart, reset, gtpready;
	wire [1:0] dpisk0, dpisk1, scrisk0, scrisk1, txisk0, txisk1;
	wire [2:0] phymode, prbssel;
	wire [3:0] fclk, fresetn;
	wire [15:0] dpdat0, dpdat1, scrdat0, scrdat1, txdat0, txdat1;
	wire [47:0] fifodo;
	wire [`ATTRMAX:0] attr;
	
	wire clk = fclk[0];
	wire resetn = fresetn[0];

	axi3 axi3_0(
		clk, resetn,

		gp0_arvalid, gp0_awvalid, gp0_bready, gp0_rready, gp0_wlast, gp0_wvalid, gp0_arid, gp0_awid,
		gp0_wid, gp0_arburst, gp0_arlock, gp0_arsize, gp0_awburst, gp0_awlock, gp0_awsize, gp0_arprot,
		gp0_awprot, gp0_araddr, gp0_awaddr, gp0_wdata, gp0_arcache, gp0_arlen, gp0_arqos, gp0_awcache,
		gp0_awlen, gp0_awqos, gp0_wstrb, gp0_arready, gp0_awready, gp0_bvalid, gp0_rlast, gp0_rvalid,
		gp0_wready, gp0_bid, gp0_rid, gp0_bresp, gp0_rresp, gp0_rdata,

		armaddr, armrdata, armwdata, armwr, armreq, armack, armwstrb, armerr
	);

	regs regs0(clk, armaddr, armrdata, armwdata, armwr, armreq, armack, armwstrb, armerr,
		auxaddr, auxwdata, auxreq, auxwr, auxack, auxerr, auxrdata,
		debugaddr, debugreq, debugack, debugrdata,
		attr, reset, phymode, prbssel);
	aux aux0(clk, auxaddr, auxwdata, auxreq, auxwr, auxack, auxerr, auxrdata, auxi, auxo, auxd);
	pxclk pxclk0(dpclk, attr, reset, dphstart, dpvstart);
	reg r0, r1;
	always @(posedge dpclk) r0 <= r0 ^ dphstart;
	always @(posedge dpclk) r1 <= r1 ^ dpvstart;
	assign debug = r0 | armack | (|armrdata);
	assign debug2 = r1;
	assign fifodo = 'hFFCCAAFFCCAA;
	stuff stuff0(dpclk, fifoempty, fifodo, fiforden, dphstart, dpvstart, dpdat0, dpdat1, dpisk0, dpisk1, attr, reset);
	scrambler scr0(dpclk, dpdat0, dpisk0, scrdat0, scrisk0);
	scrambler scr1(dpclk, dpdat1, dpisk1, scrdat1, scrisk1);
	phy phy0(dpclk, phymode, scrdat0, scrdat1, scrisk0, scrisk1, txdat0, txdat1, txisk0, txisk1);
	gtp gtp0(clk, refclk, dpclk, gtpready, prbssel, txdat0, txdat1, txisk0, txisk1, tx);
	debugm debugm0(clk, dpclk, dpdat0, dpdat1, dpisk0, dpisk1, debugaddr, debugreq, debugack, debugrdata);

	wire auxi0;
	sync auxsync(clk, !auxi0, auxi);
	PULLUP p0(.O(auxp));
	PULLDOWN p1(.O(auxn));
	IOBUFDS #(.DIFF_TERM("false"), .IOSTANDARD("BLVDS_25")) io_1(.I(!auxo), .O(auxi0), .T(auxd), .IO(auxp), .IOB(auxn));

	PS7 PS7_0(
		.MAXIGP0ARVALID(gp0_arvalid),
		.MAXIGP0AWVALID(gp0_awvalid),
		.MAXIGP0BREADY(gp0_bready),
		.MAXIGP0RREADY(gp0_rready),
		.MAXIGP0WLAST(gp0_wlast),
		.MAXIGP0WVALID(gp0_wvalid),
		.MAXIGP0ARID(gp0_arid),
		.MAXIGP0AWID(gp0_awid),
		.MAXIGP0WID(gp0_wid),
		.MAXIGP0ARBURST(gp0_arburst),
		.MAXIGP0ARLOCK(gp0_arlock),
		.MAXIGP0ARSIZE(gp0_arsize),
		.MAXIGP0AWBURST(gp0_awburst),
		.MAXIGP0AWLOCK(gp0_awlock),
		.MAXIGP0AWSIZE(gp0_awsize),
		.MAXIGP0ARPROT(gp0_arprot),
		.MAXIGP0AWPROT(gp0_awprot),
		.MAXIGP0ARADDR(gp0_araddr),
		.MAXIGP0AWADDR(gp0_awaddr),
		.MAXIGP0WDATA(gp0_wdata),
		.MAXIGP0ARCACHE(gp0_arcache),
		.MAXIGP0ARLEN(gp0_arlen),
		.MAXIGP0ARQOS(gp0_arqos),
		.MAXIGP0AWCACHE(gp0_awcache),
		.MAXIGP0AWLEN(gp0_awlen),
		.MAXIGP0AWQOS(gp0_awqos),
		.MAXIGP0WSTRB(gp0_wstrb),
		.MAXIGP0ACLK(clk),
		.MAXIGP0ARREADY(gp0_arready),
		.MAXIGP0AWREADY(gp0_awready),
		.MAXIGP0BVALID(gp0_bvalid),
		.MAXIGP0RLAST(gp0_rlast),
		.MAXIGP0RVALID(gp0_rvalid),
		.MAXIGP0WREADY(gp0_wready),
		.MAXIGP0BID(gp0_bid),
		.MAXIGP0RID(gp0_rid),
		.MAXIGP0BRESP(gp0_bresp),
		.MAXIGP0RRESP(gp0_rresp),
		.MAXIGP0RDATA(gp0_rdata),

		.FCLKCLK(fclk),
		.FCLKRESETN(fresetn)
	);

endmodule
