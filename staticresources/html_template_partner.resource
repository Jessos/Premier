(function() {

	this.premierAPI = {
		head: function() {
			document.write('\
					<meta name="viewport" content="width=device-width, initial-scale=1.0">\
					<meta name="apple-mobile-web-app-capable" content="yes"/>\
			');
		},
		header: function() {
			document.write('\
	<div id="container">\
		<header>\
			<a href="http://www.premiertalentpartners.com" title="Premier" class="logo">Premier</a>\
			<nav>\
				<ul>\
					<li class="left"><a href="http://www.premiertalentpartners.com/problems-we-solve/" title="Problems We Solve">Problems We Solve</a></li>\
					<li class="left"><a href="http://www.premiertalentpartners.com/who-we-are/" title="Who We Are">Who We Are</a></li>\
					<li class="left"><a href="http://www.premiertalentpartners.com/resources/" title="Resources">Resources</a></li>\
					<li class="left"><a href="https://www.premiertalentpartners.com/job-seekers/faq/" title="FAQ">FAQ</a></li>\
					<!-- <li>\
						<a href="http://premierstaffing.force.com/careers/ts2__SiteLogin" title="Private Login">Private Login</a>\
					</li> -->\
					<li>\
						<a href="https://jobs.premiertalentpartners.com/" title="Browse Jobs">Browse Jobs</a>\
					</li>\
				</ul>\
			</nav>\
			<div class="share">\
				<!-- AddThis Button BEGIN -->\
				<div class="addthis_toolbox addthis_default_style ">\
					<a class="addthis_button_preferred_1"></a>\
					<a class="addthis_button_preferred_2"></a>\
					<a class="addthis_button_preferred_3"></a>\
					<a class="addthis_button_preferred_4"></a>\
					<a class="addthis_button_compact"></a>\
					<a class="addthis_counter addthis_bubble_style"></a>\
				</div>\
				<script type="text/javascript" src="//s7.addthis.com/js/250/addthis_widget.js#pubid=deedod"></script>\
				<!-- AddThis Button END -->\
			</div>\
		</header>\
		<div id="main">\
			');

		},
		footer: function() {
			document.write('\
		</div>\
		<footer>\
			<nav>\
				<ul>\
					<li><a href="https://www.premiertalentpartners.com/careers/" title="Careers">Careers</a></li>\
					<li><a href="https://www.premiertalentpartners.com/privacy/" title="Privacy Policy">Privacy Policy</a></li>\
					<li><a href="https://www.premiertalentpartners.com/contact/" title="Contact Us">Contact Us</a></li>\
					<li><a href="https://www.premiertalentpartners.com/directory/" title="Locations">Locations</a></li>\
					
				</ul>\
			</nav>\
			<nav class="share">\
				<ul>\
					<li><a href="https://www.facebook.com/PremierTalentPartners" class="ir fb" title="Facebook" target="_blank">Facebook</a></li>\
					<li><a href="https://twitter.com/premiertp" class="ir tweet" title="Twitter" target="_blank">Twitter</a></li>\
					<li><a href="https://www.linkedin.com/company/premier-talent-partners/" class="ir li" title="LinkedIn" target="_blank">LinkedIn</a></li>\
					<li><a href="https://plus.google.com/#108090306470723583774/posts" class="ir google" title="Google+" target="_blank">Google+</a></li>\
					<li><a href="http://www.youtube.com/user/premierstaffinginc" class="ir yt" title="YouTube" target="_blank">YouTube</a></li>\
				</ul>\
			</nav>\
		</footer>\
	</div>\
			');
		}
	};

}());
