(window["webpackJsonpstar-admin-free-react"]=window["webpackJsonpstar-admin-free-react"]||[]).push([[8],{301:function(e,a,t){e.exports=t.p+"static/media/face4.4436c728.jpg"},302:function(e,a,t){e.exports=t.p+"static/media/face5.4436c728.jpg"},303:function(e,a,t){e.exports=t.p+"static/media/face6.4436c728.jpg"},304:function(e,a,t){e.exports=t.p+"static/media/face7.4436c728.jpg"},308:function(e,a,t){"use strict";var l=t(1),n=t(2),r=t(7),c=t.n(r),m=t(0),d=t.n(m),s=t(9);var E=1e3;function u(e,a,t){var l=(e-a)/(t-a)*100;return Math.round(l*E)/E}function i(e,a){var t,r=e.min,m=e.now,s=e.max,E=e.label,i=e.srOnly,o=e.striped,b=e.animated,N=e.className,g=e.style,p=e.variant,h=e.bsPrefix,v=Object(n.a)(e,["min","now","max","label","srOnly","striped","animated","className","style","variant","bsPrefix"]);return d.a.createElement("div",Object(l.a)({ref:a},v,{role:"progressbar",className:c()(N,h+"-bar",(t={},t["bg-"+p]=p,t[h+"-bar-animated"]=b,t[h+"-bar-striped"]=b||o,t)),style:Object(l.a)({width:u(m,r,s)+"%"},g),"aria-valuenow":m,"aria-valuemin":r,"aria-valuemax":s}),i?d.a.createElement("span",{className:"sr-only"},E):E)}var o=d.a.forwardRef((function(e,a){var t=e.isChild,r=Object(n.a)(e,["isChild"]);if(r.bsPrefix=Object(s.b)(r.bsPrefix,"progress"),t)return i(r,a);var E=r.min,u=r.now,o=r.max,b=r.label,N=r.srOnly,g=r.striped,p=r.animated,h=r.bsPrefix,v=r.variant,y=r.className,f=r.children,w=Object(n.a)(r,["min","now","max","label","srOnly","striped","animated","bsPrefix","variant","className","children"]);return d.a.createElement("div",Object(l.a)({ref:a},w,{className:c()(y,h)}),f?function(e,a){var t=0;return d.a.Children.map(e,(function(e){return d.a.isValidElement(e)?a(e,t++):e}))}(f,(function(e){return Object(m.cloneElement)(e,{isChild:!0})})):i({min:E,now:u,max:o,label:b,srOnly:N,striped:g,animated:p,bsPrefix:h,variant:v},a))}));o.displayName="ProgressBar",o.defaultProps={min:0,max:100,animated:!1,isChild:!1,srOnly:!1,striped:!1};a.a=o},314:function(e,a,t){"use strict";t.r(a),t.d(a,"BasicTable",(function(){return u}));var l=t(10),n=t(11),r=t(13),c=t(12),m=t(14),d=t(0),s=t.n(d),E=t(308),u=function(e){function a(){return Object(l.a)(this,a),Object(r.a)(this,Object(c.a)(a).apply(this,arguments))}return Object(m.a)(a,e),Object(n.a)(a,[{key:"render",value:function(){return s.a.createElement("div",null,s.a.createElement("div",{className:"page-header"},s.a.createElement("h3",{className:"page-title"}," Basic Tables "),s.a.createElement("nav",{"aria-label":"breadcrumb"},s.a.createElement("ol",{className:"breadcrumb"},s.a.createElement("li",{className:"breadcrumb-item"},s.a.createElement("a",{href:"!#",onClick:function(e){return e.preventDefault()}},"Tables")),s.a.createElement("li",{className:"breadcrumb-item active","aria-current":"page"},"Basic tables")))),s.a.createElement("div",{className:"row"},s.a.createElement("div",{className:"col-lg-6 grid-margin stretch-card"},s.a.createElement("div",{className:"card"},s.a.createElement("div",{className:"card-body"},s.a.createElement("h4",{className:"card-title"},"Basic Table"),s.a.createElement("p",{className:"card-description"}," Add className ",s.a.createElement("code",null,".table")),s.a.createElement("div",{className:"table-responsive"},s.a.createElement("table",{className:"table"},s.a.createElement("thead",null,s.a.createElement("tr",null,s.a.createElement("th",null,"Profile"),s.a.createElement("th",null,"VatNo."),s.a.createElement("th",null,"Created"),s.a.createElement("th",null,"Status"))),s.a.createElement("tbody",null,s.a.createElement("tr",null,s.a.createElement("td",null,"Jacob"),s.a.createElement("td",null,"53275531"),s.a.createElement("td",null,"12 May 2017"),s.a.createElement("td",null,s.a.createElement("label",{className:"badge badge-danger"},"Pending"))),s.a.createElement("tr",null,s.a.createElement("td",null,"Messsy"),s.a.createElement("td",null,"53275532"),s.a.createElement("td",null,"15 May 2017"),s.a.createElement("td",null,s.a.createElement("label",{className:"badge badge-warning"},"In progress"))),s.a.createElement("tr",null,s.a.createElement("td",null,"John"),s.a.createElement("td",null,"53275533"),s.a.createElement("td",null,"14 May 2017"),s.a.createElement("td",null,s.a.createElement("label",{className:"badge badge-info"},"Fixed"))),s.a.createElement("tr",null,s.a.createElement("td",null,"Peter"),s.a.createElement("td",null,"53275534"),s.a.createElement("td",null,"16 May 2017"),s.a.createElement("td",null,s.a.createElement("label",{className:"badge badge-success"},"Completed"))),s.a.createElement("tr",null,s.a.createElement("td",null,"Dave"),s.a.createElement("td",null,"53275535"),s.a.createElement("td",null,"20 May 2017"),s.a.createElement("td",null,s.a.createElement("label",{className:"badge badge-warning"},"In progress"))))))))),s.a.createElement("div",{className:"col-lg-6 grid-margin stretch-card"},s.a.createElement("div",{className:"card"},s.a.createElement("div",{className:"card-body"},s.a.createElement("h4",{className:"card-title"},"Hoverable Table"),s.a.createElement("p",{className:"card-description"}," Add className ",s.a.createElement("code",null,".table-hover")),s.a.createElement("div",{className:"table-responsive"},s.a.createElement("table",{className:"table table-hover"},s.a.createElement("thead",null,s.a.createElement("tr",null,s.a.createElement("th",null,"User"),s.a.createElement("th",null,"Product"),s.a.createElement("th",null,"Sale"),s.a.createElement("th",null,"Status"))),s.a.createElement("tbody",null,s.a.createElement("tr",null,s.a.createElement("td",null,"Jacob"),s.a.createElement("td",null,"Photoshop"),s.a.createElement("td",{className:"text-danger"}," 28.76% ",s.a.createElement("i",{className:"mdi mdi-arrow-down"})),s.a.createElement("td",null,s.a.createElement("label",{className:"badge badge-danger"},"Pending"))),s.a.createElement("tr",null,s.a.createElement("td",null,"Messsy"),s.a.createElement("td",null,"Flash"),s.a.createElement("td",{className:"text-danger"}," 21.06% ",s.a.createElement("i",{className:"mdi mdi-arrow-down"})),s.a.createElement("td",null,s.a.createElement("label",{className:"badge badge-warning"},"In progress"))),s.a.createElement("tr",null,s.a.createElement("td",null,"John"),s.a.createElement("td",null,"Premier"),s.a.createElement("td",{className:"text-danger"}," 35.00% ",s.a.createElement("i",{className:"mdi mdi-arrow-down"})),s.a.createElement("td",null,s.a.createElement("label",{className:"badge badge-info"},"Fixed"))),s.a.createElement("tr",null,s.a.createElement("td",null,"Peter"),s.a.createElement("td",null,"After effects"),s.a.createElement("td",{className:"text-success"}," 82.00% ",s.a.createElement("i",{className:"mdi mdi-arrow-up"})),s.a.createElement("td",null,s.a.createElement("label",{className:"badge badge-success"},"Completed"))),s.a.createElement("tr",null,s.a.createElement("td",null,"Dave"),s.a.createElement("td",null,"53275535"),s.a.createElement("td",{className:"text-success"}," 98.05% ",s.a.createElement("i",{className:"mdi mdi-arrow-up"})),s.a.createElement("td",null,s.a.createElement("label",{className:"badge badge-warning"},"In progress"))))))))),s.a.createElement("div",{className:"col-lg-12 grid-margin stretch-card"},s.a.createElement("div",{className:"card"},s.a.createElement("div",{className:"card-body"},s.a.createElement("h4",{className:"card-title"},"Striped Table"),s.a.createElement("p",{className:"card-description"}," Add className ",s.a.createElement("code",null,".table-striped")),s.a.createElement("div",{className:"table-responsive"},s.a.createElement("table",{className:"table table-striped"},s.a.createElement("thead",null,s.a.createElement("tr",null,s.a.createElement("th",null," User "),s.a.createElement("th",null," First name "),s.a.createElement("th",null," Progress "),s.a.createElement("th",null," Amount "),s.a.createElement("th",null," Deadline "))),s.a.createElement("tbody",null,s.a.createElement("tr",null,s.a.createElement("td",{className:"py-1"},s.a.createElement("img",{src:t(54),alt:"user icon"})),s.a.createElement("td",null," Herman Beck "),s.a.createElement("td",null,s.a.createElement(E.a,{variant:"success",now:25})),s.a.createElement("td",null," $ 77.99 "),s.a.createElement("td",null," May 15, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",{className:"py-1"},s.a.createElement("img",{src:t(97),alt:"user icon"})),s.a.createElement("td",null," Messsy Adam "),s.a.createElement("td",null,s.a.createElement(E.a,{variant:"danger",now:75})),s.a.createElement("td",null," $245.30 "),s.a.createElement("td",null," July 1, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",{className:"py-1"},s.a.createElement("img",{src:t(98),alt:"user icon"})),s.a.createElement("td",null," John Richards "),s.a.createElement("td",null,s.a.createElement(E.a,{variant:"warning",now:90})),s.a.createElement("td",null," $138.00 "),s.a.createElement("td",null," Apr 12, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",{className:"py-1"},s.a.createElement("img",{src:t(301),alt:"user icon"})),s.a.createElement("td",null," Peter Meggik "),s.a.createElement("td",null,s.a.createElement(E.a,{variant:"primary",now:50})),s.a.createElement("td",null," $ 77.99 "),s.a.createElement("td",null," May 15, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",{className:"py-1"},s.a.createElement("img",{src:t(302),alt:"user icon"})),s.a.createElement("td",null," Edward "),s.a.createElement("td",null,s.a.createElement(E.a,{variant:"danger",now:60})),s.a.createElement("td",null," $ 160.25 "),s.a.createElement("td",null," May 03, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",{className:"py-1"},s.a.createElement("img",{src:t(303),alt:"user icon"})),s.a.createElement("td",null," John Doe "),s.a.createElement("td",null,s.a.createElement(E.a,{variant:"info",now:65})),s.a.createElement("td",null," $ 123.21 "),s.a.createElement("td",null," April 05, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",{className:"py-1"},s.a.createElement("img",{src:t(304),alt:"user icon"})),s.a.createElement("td",null," Henry Tom "),s.a.createElement("td",null,s.a.createElement(E.a,{variant:"warning",now:20})),s.a.createElement("td",null," $ 150.00 "),s.a.createElement("td",null," June 16, 2015 ")))))))),s.a.createElement("div",{className:"col-lg-12 grid-margin stretch-card"},s.a.createElement("div",{className:"card"},s.a.createElement("div",{className:"card-body"},s.a.createElement("h4",{className:"card-title"},"Bordered table"),s.a.createElement("p",{className:"card-description"}," Add className ",s.a.createElement("code",null,".table-bordered")),s.a.createElement("div",{className:"table-responsive"},s.a.createElement("table",{className:"table table-bordered"},s.a.createElement("thead",null,s.a.createElement("tr",null,s.a.createElement("th",null," # "),s.a.createElement("th",null," First name "),s.a.createElement("th",null," Progress "),s.a.createElement("th",null," Amount "),s.a.createElement("th",null," Deadline "))),s.a.createElement("tbody",null,s.a.createElement("tr",null,s.a.createElement("td",null," 1 "),s.a.createElement("td",null," Herman Beck "),s.a.createElement("td",null,s.a.createElement(E.a,{variant:"success",now:25})),s.a.createElement("td",null," $ 77.99 "),s.a.createElement("td",null," May 15, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",null," 2 "),s.a.createElement("td",null," Messsy Adam "),s.a.createElement("td",null,s.a.createElement(E.a,{variant:"danger",now:75})),s.a.createElement("td",null," $245.30 "),s.a.createElement("td",null," July 1, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",null," 3 "),s.a.createElement("td",null," John Richards "),s.a.createElement("td",null,s.a.createElement(E.a,{variant:"warning",now:90})),s.a.createElement("td",null," $138.00 "),s.a.createElement("td",null," Apr 12, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",null," 4 "),s.a.createElement("td",null," Peter Meggik "),s.a.createElement("td",null,s.a.createElement(E.a,{variant:"primary",now:50})),s.a.createElement("td",null," $ 77.99 "),s.a.createElement("td",null," May 15, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",null," 5 "),s.a.createElement("td",null," Edward "),s.a.createElement("td",null,s.a.createElement(E.a,{variant:"danger",now:35})),s.a.createElement("td",null," $ 160.25 "),s.a.createElement("td",null," May 03, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",null," 6 "),s.a.createElement("td",null," John Doe "),s.a.createElement("td",null,s.a.createElement(E.a,{variant:"info",now:65})),s.a.createElement("td",null," $ 123.21 "),s.a.createElement("td",null," April 05, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",null," 7 "),s.a.createElement("td",null," Henry Tom "),s.a.createElement("td",null,s.a.createElement(E.a,{now:60}),s.a.createElement(E.a,{variant:"warning",now:20})),s.a.createElement("td",null," $ 150.00 "),s.a.createElement("td",null," June 16, 2015 ")))))))),s.a.createElement("div",{className:"col-lg-12 grid-margin stretch-card"},s.a.createElement("div",{className:"card"},s.a.createElement("div",{className:"card-body"},s.a.createElement("h4",{className:"card-title"},"Inverse table"),s.a.createElement("p",{className:"card-description"}," Add className ",s.a.createElement("code",null,".table-dark")),s.a.createElement("div",{className:"table-responsive"},s.a.createElement("table",{className:"table table-dark"},s.a.createElement("thead",null,s.a.createElement("tr",null,s.a.createElement("th",null," # "),s.a.createElement("th",null," First name "),s.a.createElement("th",null," Amount "),s.a.createElement("th",null," Deadline "))),s.a.createElement("tbody",null,s.a.createElement("tr",null,s.a.createElement("td",null," 1 "),s.a.createElement("td",null," Herman Beck "),s.a.createElement("td",null," $ 77.99 "),s.a.createElement("td",null," May 15, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",null," 2 "),s.a.createElement("td",null," Messsy Adam "),s.a.createElement("td",null," $245.30 "),s.a.createElement("td",null," July 1, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",null," 3 "),s.a.createElement("td",null," John Richards "),s.a.createElement("td",null," $138.00 "),s.a.createElement("td",null," Apr 12, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",null," 4 "),s.a.createElement("td",null," Peter Meggik "),s.a.createElement("td",null," $ 77.99 "),s.a.createElement("td",null," May 15, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",null," 5 "),s.a.createElement("td",null," Edward "),s.a.createElement("td",null," $ 160.25 "),s.a.createElement("td",null," May 03, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",null," 6 "),s.a.createElement("td",null," John Doe "),s.a.createElement("td",null," $ 123.21 "),s.a.createElement("td",null," April 05, 2015 ")),s.a.createElement("tr",null,s.a.createElement("td",null," 7 "),s.a.createElement("td",null," Henry Tom "),s.a.createElement("td",null," $ 150.00 "),s.a.createElement("td",null," June 16, 2015 ")))))))),s.a.createElement("div",{className:"col-lg-12 stretch-card"},s.a.createElement("div",{className:"card"},s.a.createElement("div",{className:"card-body"},s.a.createElement("h4",{className:"card-title"},"Table with contextual classNames"),s.a.createElement("p",{className:"card-description"}," Add className ",s.a.createElement("code",null,".table-{color}")),s.a.createElement("div",{className:"table-responsive"},s.a.createElement("table",{className:"table table-bordered"},s.a.createElement("thead",null,s.a.createElement("tr",null,s.a.createElement("th",null," # "),s.a.createElement("th",null," First name "),s.a.createElement("th",null," Product "),s.a.createElement("th",null," Amount "),s.a.createElement("th",null," Deadline "))),s.a.createElement("tbody",null,s.a.createElement("tr",{className:"table-info"},s.a.createElement("td",null," 1 "),s.a.createElement("td",null," Herman Beck "),s.a.createElement("td",null," Photoshop "),s.a.createElement("td",null," $ 77.99 "),s.a.createElement("td",null," May 15, 2015 ")),s.a.createElement("tr",{className:"table-warning"},s.a.createElement("td",null," 2 "),s.a.createElement("td",null," Messsy Adam "),s.a.createElement("td",null," Flash "),s.a.createElement("td",null," $245.30 "),s.a.createElement("td",null," July 1, 2015 ")),s.a.createElement("tr",{className:"table-danger"},s.a.createElement("td",null," 3 "),s.a.createElement("td",null," John Richards "),s.a.createElement("td",null," Premeire "),s.a.createElement("td",null," $138.00 "),s.a.createElement("td",null," Apr 12, 2015 ")),s.a.createElement("tr",{className:"table-success"},s.a.createElement("td",null," 4 "),s.a.createElement("td",null," Peter Meggik "),s.a.createElement("td",null," After effects "),s.a.createElement("td",null," $ 77.99 "),s.a.createElement("td",null," May 15, 2015 ")),s.a.createElement("tr",{className:"table-primary"},s.a.createElement("td",null," 5 "),s.a.createElement("td",null," Edward "),s.a.createElement("td",null," Illustrator "),s.a.createElement("td",null," $ 160.25 "),s.a.createElement("td",null," May 03, 2015 "))))))))))}}]),a}(d.Component);a.default=u},97:function(e,a,t){e.exports=t.p+"static/media/face2.4436c728.jpg"},98:function(e,a,t){e.exports=t.p+"static/media/face3.4436c728.jpg"}}]);
//# sourceMappingURL=8.440fc7cf.chunk.js.map