import 'package:flutter/material.dart';

class Company {
  final int id;
  final String name;
  final String city;
  final String state;
  final String type;
  final String size;
  final int openings;
  final String domain;
  final String logo;
  final String desc;
  final String website;
  final double lat;
  final double lng;

  Company({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.type,
    required this.size,
    required this.openings,
    required this.domain,
    required this.logo,
    required this.desc,
    required this.website,
    required this.lat,
    required this.lng,
  });
}

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  int? selected;
  String view = "list";
  String filter = "All";

  final filters = ["All", "MNC", "Startup", "Unicorn", "Government"];

  final List<Company> companies = [
    Company(
      id: 1,
      name: "Infosys",
      city: "Bangalore",
      state: "Karnataka",
      type: "MNC",
      size: "300K+ employees",
      openings: 45,
      domain: "IT Services",
      logo: "🔵",
      desc: "Global leader in digital services and consulting.",
      website: "infosys.com",
      lat: 12.97,
      lng: 77.59,
    ),
    Company(
      id: 2,
      name: "Flipkart",
      city: "Bangalore",
      state: "Karnataka",
      type: "Startup",
      size: "30K+ employees",
      openings: 28,
      domain: "E-Commerce",
      logo: "🟡",
      desc: "India's largest e-commerce marketplace.",
      website: "flipkart.com",
      lat: 12.95,
      lng: 77.67,
    ),
    Company(
      id: 3,
      name: "Zepto",
      city: "Mumbai",
      state: "Maharashtra",
      type: "Startup",
      size: "3K+ employees",
      openings: 12,
      domain: "Quick Commerce",
      logo: "⚡",
      desc: "10-minute grocery delivery startup.",
      website: "zepto.com",
      lat: 19.07,
      lng: 72.87,
    ),
    Company(
      id: 4,
      name: "ISRO",
      city: "Bangalore",
      state: "Karnataka",
      type: "Government",
      size: "16K+ employees",
      openings: 8,
      domain: "Space & Research",
      logo: "🚀",
      desc: "India's national space agency.",
      website: "isro.gov.in",
      lat: 13.02,
      lng: 77.57,
    ),
    Company(
      id: 5,
      name: "Razorpay",
      city: "Bangalore",
      state: "Karnataka",
      type: "Unicorn",
      size: "2.5K+ employees",
      openings: 18,
      domain: "Fintech",
      logo: "💙",
      desc: "Full-stack financial solutions company.",
      website: "razorpay.com",
      lat: 12.93,
      lng: 77.62,
    ),
  ];

  Color typeColor(String type) {
    switch (type) {
      case "MNC":
        return Colors.blue;
      case "Startup":
        return Colors.orange;
      case "Government":
        return Colors.green;
      case "Unicorn":
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filter == "All"
        ? companies
        : companies.where((c) => c.type == filter).toList();

    final company =
    companies.firstWhere((c) => c.id == selected, orElse: () => Company(
      id: 0,
      name: "",
      city: "",
      state: "",
      type: "",
      size: "",
      openings: 0,
      domain: "",
      logo: "",
      desc: "",
      website: "",
      lat: 0,
      lng: 0,
    ));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Companies"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// VIEW TOGGLE
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: ["list", "map"].map((v) {
                      final active = view == v;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            view = v;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                            active ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            v,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: active
                                    ? Colors.blue
                                    : Colors.grey),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              ],
            ),

            const SizedBox(height: 16),

            /// FILTERS
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: filters.map((f) {
                  final active = filter == f;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        active ? Colors.blue : Colors.white,
                        foregroundColor:
                        active ? Colors.white : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          filter = f;
                        });
                      },
                      child: Text(f),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            /// LIST VIEW
            if (view == "list")
              Expanded(
                child: Row(
                  children: [

                    /// COMPANY LIST
                    Expanded(
                      flex: 3,
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final c = filtered[i];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selected = c.id;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected == c.id
                                      ? Colors.blue
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(c.logo,
                                      style:
                                      const TextStyle(fontSize: 30)),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(c.name,
                                                style: const TextStyle(
                                                    fontWeight:
                                                    FontWeight
                                                        .bold)),
                                            Container(
                                              padding:
                                              const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 8,
                                                  vertical: 4),
                                              decoration: BoxDecoration(
                                                color: typeColor(
                                                    c.type)
                                                    .withOpacity(.1),
                                                borderRadius:
                                                BorderRadius
                                                    .circular(6),
                                              ),
                                              child: Text(
                                                c.type,
                                                style: TextStyle(
                                                    color: typeColor(
                                                        c.type),
                                                    fontSize: 12),
                                              ),
                                            )
                                          ],
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          "${c.city}, ${c.state}",
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12),
                                        ),

                                        const SizedBox(height: 6),

                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Text(c.domain,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                    Colors.grey)),
                                            Text(
                                              "${c.openings} openings",
                                              style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// DETAIL PANEL
                    // Expanded(
                    //   flex: 2,
                    //   child: selected == null
                    //       ? const Center(
                    //       child: Text(
                    //           ""))
                    //       : Container(
                    //     padding: const EdgeInsets.all(16),
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius:
                    //       BorderRadius.circular(16),
                    //     ),
                    //     child: Column(
                    //       crossAxisAlignment:
                    //       CrossAxisAlignment.start,
                    //       children: [
                    //         Text(company.logo,
                    //             style:
                    //             const TextStyle(fontSize: 40)),
                    //         const SizedBox(height: 10),
                    //         Text(company.name,
                    //             style: const TextStyle(
                    //                 fontWeight: FontWeight.bold,
                    //                 fontSize: 20)),
                    //         const SizedBox(height: 8),
                    //         Text(company.desc,
                    //             style: const TextStyle(
                    //                 color: Colors.grey)),
                    //         const SizedBox(height: 20),
                    //
                    //         Text(
                    //             "Location: ${company.city}, ${company.state}"),
                    //         Text("Team: ${company.size}"),
                    //         Text("Domain: ${company.domain}"),
                    //         Text("Website: ${company.website}"),
                    //
                    //         const Spacer(),
                    //
                    //         ElevatedButton(
                    //           onPressed: () {},
                    //           child: Text(
                    //               "View Openings (${company.openings})"),
                    //         )
                    //       ],
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              )

            /// MAP VIEW
            /// else
              // Expanded(
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: Colors.blue[50],
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     child: const Center(
              //       child: Text(
              //         "🗺 Map View\n(Google Maps API can be integrated here)",
              //         textAlign: TextAlign.center,
              //       ),
              //     ),
              //   ),
              // )
          ],
        ),
      ),
    );
  }
}
