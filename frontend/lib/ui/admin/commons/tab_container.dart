import 'package:flutter/material.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class TabContainer extends StatefulWidget {
  const TabContainer({super.key, required this.tabs});

  final List<OflTab> tabs;

  @override
  State<TabContainer> createState() => _TabContainerState();
}

class _TabContainerState extends State<TabContainer> {
  late int _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = 0;
  }

  void setSelectedTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [...widget.tabs.map((tab) => _buildTab(widget.tabs.indexOf(tab), _selectedTab, tab.label))],
          ),
          Expanded(child: widget.tabs[_selectedTab].content)
        ],
      ),
    );
  }

  Widget _buildTab(int tabIndex, int selectedTab, String label) {
    bool isSelected = tabIndex == selectedTab;

    return Expanded(
      child: Container(
          decoration: BoxDecoration(
            border: isSelected
                ? null
                : Border.all(
                    color: Colors.black,
                  ),
            color: !isSelected ? Colors.black12 : null,
            boxShadow: !isSelected
                ? [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10.0,
                      spreadRadius: -10.0,
                    )
                  ]
                : null,
          ),
          child: InkWell(
            onTap: () {
              setSelectedTab(tabIndex);
            },
            child: Padding(
                padding: EdgeInsets.all(smallPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label),
                  ],
                )),
          )),
    );
  }
}

class OflTab {
  final String label;
  final Widget content;

  OflTab({required this.label, required this.content});
}
