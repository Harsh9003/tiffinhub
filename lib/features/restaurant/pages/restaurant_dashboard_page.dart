import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/restaurant_model.dart';
import '../services/restaurant_service.dart';
import 'restaurant_registration_page.dart';

class RestaurantDashboardPage extends StatelessWidget {
  const RestaurantDashboardPage({super.key});

  static const Color _bg = Color(0xFFF8FAFC);
  static const Color _orange = Color(0xFFFF6A00);
  static const Color _purple = Color(0xFF6D3DEB);
  static const Color _text = Color(0xFF111827);
  static const Color _muted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RestaurantModel?>(
      stream: RestaurantService.watchMyRestaurant(),
      builder: (context, snapshot) {
        final restaurant = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(backgroundColor: _bg, body: Center(child: CircularProgressIndicator()));
        }
        if (restaurant == null) return _RegistrationRequiredView();
        if (!restaurant.isApproved || !restaurant.isActive) return _PendingApprovalView(restaurant: restaurant);
        return _ApprovedDashboard(restaurant: restaurant);
      },
    );
  }
}

class _ApprovedDashboard extends StatelessWidget {
  final RestaurantModel restaurant;
  const _ApprovedDashboard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RestaurantDashboardPage._bg,
      body: SafeArea(
        child: Row(
          children: [
            if (MediaQuery.sizeOf(context).width >= 900) _SideBar(restaurant: restaurant),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  _TopHeader(restaurant: restaurant),
                  const SizedBox(height: 16),
                  _OverviewGrid(restaurant: restaurant),
                  const SizedBox(height: 16),
                  _QuickActions(),
                  const SizedBox(height: 16),
                  LayoutBuilder(builder: (context, constraints) {
                    final wide = constraints.maxWidth > 900;
                    return wide
                        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(child: _PendingRequests(restaurant: restaurant)),
                            const SizedBox(width: 14),
                            Expanded(child: _TodayDeliveries(restaurant: restaurant)),
                            const SizedBox(width: 14),
                            SizedBox(width: 330, child: _PublicPreview(restaurant: restaurant)),
                          ])
                        : Column(children: [
                            _PendingRequests(restaurant: restaurant),
                            const SizedBox(height: 14),
                            _TodayDeliveries(restaurant: restaurant),
                            const SizedBox(height: 14),
                            _PublicPreview(restaurant: restaurant),
                          ]);
                  }),
                  const SizedBox(height: 16),
                  LayoutBuilder(builder: (context, constraints) {
                    final wide = constraints.maxWidth > 900;
                    return wide
                        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                            Expanded(child: _ActiveCustomersCard()),
                            SizedBox(width: 14),
                            Expanded(child: _RevenueAnalyticsCard()),
                            SizedBox(width: 14),
                            Expanded(child: _RenewalsCard()),
                          ])
                        : Column(children: const [_ActiveCustomersCard(), SizedBox(height: 14), _RevenueAnalyticsCard(), SizedBox(height: 14), _RenewalsCard()]);
                  }),
                  const SizedBox(height: 16),
                  LayoutBuilder(builder: (context, constraints) {
                    final wide = constraints.maxWidth > 900;
                    return wide
                        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                            Expanded(child: _ComplaintCenterCard()),
                            SizedBox(width: 14),
                            Expanded(child: _LatestReviewsCard()),
                            SizedBox(width: 14),
                            Expanded(child: _HealthScoreCard()),
                          ])
                        : Column(children: const [_ComplaintCenterCard(), SizedBox(height: 14), _LatestReviewsCard(), SizedBox(height: 14), _HealthScoreCard()]);
                  }),
                  const SizedBox(height: 16),
                  _BottomTip(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistrationRequiredView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RestaurantDashboardPage._bg,
      body: Center(
        child: _SimpleStateCard(
          icon: Icons.storefront_rounded,
          title: 'Restaurant Profile Required',
          message: 'Complete your restaurant registration to start receiving subscription requests.',
          buttonText: 'Start Registration',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RestaurantRegistrationPage())),
        ),
      ),
    );
  }
}

class _PendingApprovalView extends StatelessWidget {
  final RestaurantModel restaurant;
  const _PendingApprovalView({required this.restaurant});
  @override
  Widget build(BuildContext context) {
    final rejected = restaurant.registrationStatus == 'rejected';
    return Scaffold(
      backgroundColor: RestaurantDashboardPage._bg,
      body: Center(
        child: _SimpleStateCard(
          icon: rejected ? Icons.cancel_rounded : Icons.pending_actions_rounded,
          title: rejected ? 'Registration Requires Changes' : 'Registration Under Review',
          message: rejected
              ? (restaurant.rejectionReason.isNotEmpty ? restaurant.rejectionReason : 'Admin has requested changes in your restaurant profile.')
              : 'Your submitted restaurant profile is waiting for admin approval. The dashboard will unlock after approval.',
          buttonText: 'Edit Registration',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RestaurantRegistrationPage())),
        ),
      ),
    );
  }
}

class _SimpleStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onTap;
  const _SimpleStateCard({required this.icon, required this.title, required this.message, required this.buttonText, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
    width: 420,
    margin: const EdgeInsets.all(20),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 22)]),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      CircleAvatar(radius: 32, backgroundColor: const Color(0xFFFFEFE4), child: Icon(icon, color: RestaurantDashboardPage._orange, size: 30)),
      const SizedBox(height: 14),
      Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
      const SizedBox(height: 8),
      Text(message, textAlign: TextAlign.center, style: const TextStyle(color: RestaurantDashboardPage._muted, fontWeight: FontWeight.w700, height: 1.35)),
      const SizedBox(height: 18),
      SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: RestaurantDashboardPage._orange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.w900)))),
    ]),
  );
}

class _SideBar extends StatelessWidget {
  final RestaurantModel restaurant;
  const _SideBar({required this.restaurant});
  @override
  Widget build(BuildContext context) => Container(
    width: 248,
    color: Colors.white,
    padding: const EdgeInsets.all(14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [CircleAvatar(backgroundColor: const Color(0xFFFFEFE4), child: Text(restaurant.restaurantName.substring(0, 1), style: const TextStyle(color: RestaurantDashboardPage._orange, fontWeight: FontWeight.w900))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(restaurant.restaurantName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)), const Text('Restaurant Dashboard', style: TextStyle(color: RestaurantDashboardPage._muted, fontSize: 12, fontWeight: FontWeight.w700))]))]),
      const SizedBox(height: 24),
      ...['Dashboard','Requests','Deliveries','Customers','Subscriptions','Complaints','Reviews','Menu & Plans','Reports & Analytics','Earnings','Wallet & Payments','Delivery Partners','Profile Preview','Restaurant Profile','Settings','Help & Support'].map((e) => _SideItem(label: e, selected: e == 'Dashboard')).toList(),
      const Spacer(),
      Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFF8F5FF), borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Icon(Icons.support_agent_rounded, color: RestaurantDashboardPage._purple), SizedBox(height: 8), Text('Need Help?', style: TextStyle(fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('Contact support team', style: TextStyle(color: RestaurantDashboardPage._muted, fontSize: 12))])),
    ]),
  );
}

class _SideItem extends StatelessWidget {
  final String label;
  final bool selected;
  const _SideItem({required this.label, required this.selected});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
    decoration: BoxDecoration(color: selected ? RestaurantDashboardPage._purple : Colors.transparent, borderRadius: BorderRadius.circular(10)),
    child: Row(children: [Icon(Icons.circle, size: 8, color: selected ? Colors.white : RestaurantDashboardPage._muted), const SizedBox(width: 12), Text(label, style: TextStyle(color: selected ? Colors.white : RestaurantDashboardPage._text, fontWeight: FontWeight.w800, fontSize: 13))]),
  );
}

class _TopHeader extends StatelessWidget {
  final RestaurantModel restaurant;
  const _TopHeader({required this.restaurant});
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Welcome back, ${restaurant.ownerName.isEmpty ? 'Partner' : restaurant.ownerName}!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 4), const Text('Here is what is happening with your restaurant today.', style: TextStyle(color: RestaurantDashboardPage._muted, fontWeight: FontWeight.w700))])),
    _OpenStatusChip(),
  ]);
}

class _OpenStatusChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E7EB))), child: const Row(children: [Icon(Icons.circle, size: 10, color: Colors.green), SizedBox(width: 8), Text('Open Now', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w900))]));
}

class _OverviewGrid extends StatelessWidget {
  final RestaurantModel restaurant;
  const _OverviewGrid({required this.restaurant});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
    final cross = c.maxWidth > 900 ? 4 : 2;
    return GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: cross, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 2.05, children: const [
      _MetricCard(title: 'Active Customers', value: '48', sub: '12% vs yesterday', icon: Icons.group_rounded, color: Color(0xFF7C3AED)),
      _MetricCard(title: 'Today\'s Deliveries', value: '42 / 48', sub: 'Completed', icon: Icons.local_shipping_rounded, color: Color(0xFF2563EB)),
      _MetricCard(title: 'Pending Deliveries', value: '6', sub: 'Need Attention', icon: Icons.receipt_long_rounded, color: Color(0xFFFF6A00)),
      _MetricCard(title: 'Revenue Today', value: '₹4,850', sub: '18% vs yesterday', icon: Icons.payments_rounded, color: Color(0xFF16A34A)),
    ]);
  });
}

class _MetricCard extends StatelessWidget { final String title,value,sub; final IconData icon; final Color color; const _MetricCard({required this.title,required this.value,required this.sub,required this.icon,required this.color}); @override Widget build(BuildContext context)=>_Panel(child: Row(children:[CircleAvatar(backgroundColor: color.withOpacity(.10), child: Icon(icon,color:color)), const SizedBox(width:14), Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[Text(title,style:const TextStyle(color:RestaurantDashboardPage._muted,fontWeight:FontWeight.w800,fontSize:12)),Text(value,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:26)),Text(sub,style:TextStyle(color:color,fontWeight:FontWeight.w700,fontSize:12))]))])); }

class _QuickActions extends StatelessWidget { @override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Quick Actions',style:TextStyle(fontWeight:FontWeight.w900,fontSize:17)),const SizedBox(height:10),GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:MediaQuery.sizeOf(context).width>900?6:3,crossAxisSpacing:12,mainAxisSpacing:12,childAspectRatio:1.55,children:const[_ActionCard(label:'New Requests',icon:Icons.pending_actions_rounded,badge:'3'),_ActionCard(label:'Pending Deliveries',icon:Icons.delivery_dining_rounded,badge:'6'),_ActionCard(label:'Complaints',icon:Icons.notifications_active_rounded,badge:'2'),_ActionCard(label:'Customers',icon:Icons.groups_rounded),_ActionCard(label:'Menu & Plans',icon:Icons.menu_book_rounded),_ActionCard(label:'Reports',icon:Icons.trending_up_rounded)])]); }
class _ActionCard extends StatelessWidget{final String label; final IconData icon; final String? badge; const _ActionCard({required this.label,required this.icon,this.badge}); @override Widget build(BuildContext context)=>_Panel(child:Stack(children:[Center(child:Column(mainAxisSize:MainAxisSize.min,children:[CircleAvatar(backgroundColor:const Color(0xFFF3F0FF),child:Icon(icon,color:RestaurantDashboardPage._purple)),const SizedBox(height:8),Text(label,textAlign:TextAlign.center,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:12))])),if(badge!=null)Positioned(right:8,top:8,child:CircleAvatar(radius:11,backgroundColor:Colors.red,child:Text(badge!,style:const TextStyle(color:Colors.white,fontSize:11,fontWeight:FontWeight.w900))))]));}

class _PendingRequests extends StatelessWidget { final RestaurantModel restaurant; const _PendingRequests({required this.restaurant}); @override Widget build(BuildContext context)=>_Panel(title:'Pending Subscription Requests', action:'View All', child:StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream:RestaurantService.watchSubscriptionRequests(restaurant.id),builder:(context,s){final docs=s.data?.docs.where((d)=>(d.data()['status']??'')=='request_pending').take(3).toList()??[]; if(docs.isEmpty)return const _EmptyMini('No pending requests'); return Column(children:docs.map((d){final x=d.data(); return _ListRow(title:(x['customerName']??'Customer').toString(), sub:'${x['planName']??'Plan'} • ${x['mealType']??''}', trailing:'Approve');}).toList());}));}
class _TodayDeliveries extends StatelessWidget { final RestaurantModel restaurant; const _TodayDeliveries({required this.restaurant}); @override Widget build(BuildContext context)=>_Panel(title:'Today\'s Deliveries', action:'View All', child:Column(children:const[_ListRow(title:'Harshender Singh',sub:'Lunch • 1:00 PM',trailing:'Pending'),_ListRow(title:'Rohit Verma',sub:'Lunch • 1:00 PM',trailing:'Pending'),_ListRow(title:'Neha Sharma',sub:'Dinner • 8:00 PM',trailing:'Prepared'),_ListRow(title:'Amit Jain',sub:'Dinner • 8:00 PM',trailing:'Delivered')]));}
class _PublicPreview extends StatelessWidget { final RestaurantModel restaurant; const _PublicPreview({required this.restaurant}); @override Widget build(BuildContext context)=>_Panel(title:'Public Preview', child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(height:130,decoration:BoxDecoration(borderRadius:BorderRadius.circular(16),gradient:const LinearGradient(colors:[Color(0xFF2B140C),Color(0xFF8B4513)])),child:Align(alignment:Alignment.bottomLeft,child:Padding(padding:const EdgeInsets.all(14),child:Text(restaurant.restaurantName,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w900,fontSize:22))))),const SizedBox(height:12),Wrap(spacing:8,runSpacing:8,children:[_Chip('⭐ ${restaurant.rating.toStringAsFixed(1)}'),_Chip(restaurant.foodType),_Chip(restaurant.serviceAreaLabel),_Chip(restaurant.estimatedDeliveryTime)]),const SizedBox(height:12),Wrap(spacing:8,children:[if(restaurant.trialPlanEnabled)_Chip('Trial'),if(restaurant.weeklyPlanEnabled)_Chip('Weekly'),if(restaurant.monthlyPlanEnabled)_Chip('Monthly')]),const SizedBox(height:12),Wrap(spacing:8,children:[if(restaurant.isDeliveryAvailable)_Chip('Delivery'),if(restaurant.isPickupAvailable)_Chip('Self Pickup'),if(restaurant.isDineInAvailable)_Chip('Dine-In')]) ]));}
class _Chip extends StatelessWidget {final String text; const _Chip(this.text); @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),decoration:BoxDecoration(color:const Color(0xFFFFF3E8),borderRadius:BorderRadius.circular(20)),child:Text(text,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w800,color:Color(0xFF7B6250))));}

class _ActiveCustomersCard extends StatelessWidget{const _ActiveCustomersCard();@override Widget build(BuildContext context)=>_Panel(title:'Active Customers by Plan',child:const SizedBox(height:155,child:Center(child:Text('48 Total\nMonthly 31 • Weekly 12 • Trial 5',textAlign:TextAlign.center,style:TextStyle(fontWeight:FontWeight.w900,fontSize:16)))));}
class _RevenueAnalyticsCard extends StatelessWidget{const _RevenueAnalyticsCard();@override Widget build(BuildContext context)=>_Panel(title:'Revenue Analytics',action:'View Report',child:Column(children:const[_ListRow(title:'Today',sub:'',trailing:'₹4,850'),_ListRow(title:'This Week',sub:'',trailing:'₹29,000'),_ListRow(title:'This Month',sub:'',trailing:'₹1,12,000')]));}
class _RenewalsCard extends StatelessWidget{const _RenewalsCard();@override Widget build(BuildContext context)=>_Panel(title:'Expiring Soon',action:'View All',child:Column(children:const[_ListRow(title:'Harshender Singh',sub:'Monthly Plan',trailing:'2 Days'),_ListRow(title:'Rohit Verma',sub:'Weekly Plan',trailing:'3 Days'),_ListRow(title:'Amit Jain',sub:'Monthly Plan',trailing:'5 Days')]));}
class _ComplaintCenterCard extends StatelessWidget{const _ComplaintCenterCard();@override Widget build(BuildContext context)=>_Panel(title:'Complaint Center',action:'View All',child:Column(children:const[_ListRow(title:'Rohit Verma',sub:'Food was cold',trailing:'Open'),_ListRow(title:'Neha Sharma',sub:'Delivery was late',trailing:'Need Response'),_ListRow(title:'Amit Jain',sub:'Packaging issue',trailing:'Overdue')]));}
class _LatestReviewsCard extends StatelessWidget{const _LatestReviewsCard();@override Widget build(BuildContext context)=>_Panel(title:'Latest Reviews',action:'View All',child:Column(children:const[_ListRow(title:'Harshender Singh',sub:'★★★★★ Food is always on time.',trailing:'Today'),_ListRow(title:'Neha Sharma',sub:'★★★★ Good food and hygiene.',trailing:'Yesterday'),_ListRow(title:'Amit Jain',sub:'★★★★★ Best service in Jaipur.',trailing:'2 Days')]));}
class _HealthScoreCard extends StatelessWidget{const _HealthScoreCard();@override Widget build(BuildContext context)=>_Panel(title:'Restaurant Health Score',child:Column(children:const[Text('4.8',style:TextStyle(fontSize:44,fontWeight:FontWeight.w900,color:Colors.green)),Text('Excellent',style:TextStyle(color:Colors.green,fontWeight:FontWeight.w900)),SizedBox(height:12),_ListRow(title:'Response Rate',sub:'',trailing:'98%'),_ListRow(title:'Delivery Success',sub:'',trailing:'99%'),_ListRow(title:'Customer Rating',sub:'',trailing:'4.8/5')]));}
class _BottomTip extends StatelessWidget{ @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xFFF5F0FF),borderRadius:BorderRadius.circular(16)),child:const Row(children:[Icon(Icons.tips_and_updates_rounded,color:RestaurantDashboardPage._purple),SizedBox(width:10),Expanded(child:Text('Tip: Keep your menu, prices, payment details and timings updated to get more customers.',style:TextStyle(fontWeight:FontWeight.w800,color:RestaurantDashboardPage._purple)))]));}

class _Panel extends StatelessWidget { final String? title; final String? action; final Widget child; const _Panel({this.title,this.action,required this.child}); @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(18),border:Border.all(color:const Color(0xFFE5E7EB)),boxShadow:[BoxShadow(color:Colors.black.withOpacity(.035),blurRadius:16,offset:const Offset(0,8))]),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[if(title!=null)Row(children:[Expanded(child:Text(title!,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:15))),if(action!=null)Text(action!,style:const TextStyle(color:RestaurantDashboardPage._purple,fontWeight:FontWeight.w900,fontSize:12))]),if(title!=null)const SizedBox(height:12),child]));}
class _ListRow extends StatelessWidget { final String title,sub,trailing; const _ListRow({required this.title,required this.sub,required this.trailing}); @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Row(children:[CircleAvatar(radius:18,backgroundColor:const Color(0xFFF3F0FF),child:Text(title.substring(0,1),style:const TextStyle(color:RestaurantDashboardPage._purple,fontWeight:FontWeight.w900))),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:13)),if(sub.isNotEmpty)Text(sub,style:const TextStyle(color:RestaurantDashboardPage._muted,fontWeight:FontWeight.w700,fontSize:12))])),Text(trailing,style:const TextStyle(color:RestaurantDashboardPage._orange,fontWeight:FontWeight.w900,fontSize:12))]));}
class _EmptyMini extends StatelessWidget{final String text; const _EmptyMini(this.text); @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.all(16),child:Center(child:Text(text,style:const TextStyle(color:RestaurantDashboardPage._muted,fontWeight:FontWeight.w800))));}
