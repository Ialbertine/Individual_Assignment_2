// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '/api.dart';
import '/country.dart';
import 'country_details.dart';
import 'searchpage.dart';
import './country_card.dart';
import "./favoritepage.dart";

// Events
abstract class CountryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadCountriesEvent extends CountryEvent {}

class FilterCountriesByRegionEvent extends CountryEvent {
  final String region;
  FilterCountriesByRegionEvent(this.region);

  @override
  List<Object> get props => [region];
}

class ChangePaginationEvent extends CountryEvent {
  final bool isNext;
  ChangePaginationEvent(this.isNext);

  @override
  List<Object> get props => [isNext];
}

class ChangeBottomNavEvent extends CountryEvent {
  final int index;
  ChangeBottomNavEvent(this.index);

  @override
  List<Object> get props => [index];
}

// States
class CountryState extends Equatable {
  final List<Country> countries;
  final List<Country> filteredCountries;
  final bool isLoading;
  final String selectedRegion;
  final int currentPage;
  final int itemsPerPage;
  final int currentIndex;

  const CountryState({
    this.countries = const [],
    this.filteredCountries = const [],
    this.isLoading = true,
    this.selectedRegion = 'All',
    this.currentPage = 0,
    this.itemsPerPage = 10,
    this.currentIndex = 0,
  });

  CountryState copyWith({
    List<Country>? countries,
    List<Country>? filteredCountries,
    bool? isLoading,
    String? selectedRegion,
    int? currentPage,
    int? itemsPerPage,
    int? currentIndex,
  }) {
    return CountryState(
      countries: countries ?? this.countries,
      filteredCountries: filteredCountries ?? this.filteredCountries,
      isLoading: isLoading ?? this.isLoading,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  List<Country> getPaginatedCountries() {
    final start = currentPage * itemsPerPage;
    final end = start + itemsPerPage;
    return filteredCountries.sublist(
      start, 
      end > filteredCountries.length ? filteredCountries.length : end
    );
  }

  @override
  List<Object> get props => [
    countries, 
    filteredCountries, 
    isLoading, 
    selectedRegion, 
    currentPage,
    currentIndex
  ];
}

// BLoC
class CountryBloc extends Bloc<CountryEvent, CountryState> {
  final ApiService _apiService;

  CountryBloc(this._apiService) : super(const CountryState()) {
    on<LoadCountriesEvent>(_onLoadCountries);
    on<FilterCountriesByRegionEvent>(_onFilterCountries);
    on<ChangePaginationEvent>(_onChangePagination);
    on<ChangeBottomNavEvent>(_onChangeBottomNav);
  }

  Future<void> _onLoadCountries(
    LoadCountriesEvent event, 
    Emitter<CountryState> emit
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      final countries = await _apiService.getCountries();
      emit(state.copyWith(
        countries: countries,
        filteredCountries: countries,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onFilterCountries(
    FilterCountriesByRegionEvent event, 
    Emitter<CountryState> emit
  ) {
    final filteredCountries = event.region == 'All'
        ? state.countries
        : state.countries.where((c) => c.region == event.region).toList();

    emit(state.copyWith(
      filteredCountries: filteredCountries,
      selectedRegion: event.region,
      currentPage: 0,
    ));
  }

  void _onChangePagination(
    ChangePaginationEvent event, 
    Emitter<CountryState> emit
  ) {
    int newPage = state.currentPage;
    if (event.isNext && 
        (newPage + 1) * state.itemsPerPage < state.filteredCountries.length) {
      newPage++;
    } else if (!event.isNext && newPage > 0) {
      newPage--;
    }

    emit(state.copyWith(currentPage: newPage));
  }

  void _onChangeBottomNav(
    ChangeBottomNavEvent event, 
    Emitter<CountryState> emit
  ) {
    emit(state.copyWith(currentIndex: event.index));
  }
}

// HomePage with BLoC
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CountryBloc(ApiService())..add(LoadCountriesEvent()),
      child: BlocBuilder<CountryBloc, CountryState>(
        builder: (context, state) {
          final mediaQuery = MediaQuery.of(context);
          final isLandscape = mediaQuery.orientation == Orientation.landscape;
          final screenHeight = mediaQuery.size.height;
          final screenWidth = mediaQuery.size.width;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Countries Explorer'),
              backgroundColor: Colors.blue,
              elevation: 0,
            ),
            body: SafeArea(
              child: IndexedStack(
                index: state.currentIndex,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                            minWidth: constraints.maxWidth,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Enlarged image
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxHeight: isLandscape
                                        ? screenHeight * 0.3
                                        : screenHeight * 0.25),
                                child: Image.asset(
                                  'assets/world.jpg',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Responsive dropdown
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                    vertical: screenHeight * 0.01),
                                child: DropdownButtonFormField<String>(
                                  value: state.selectedRegion,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Continent',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: [
                                    'All',
                                    'Africa',
                                    'Americas',
                                    'Asia',
                                    'Europe',
                                    'Oceania'
                                  ].map((String region) {
                                    return DropdownMenuItem<String>(
                                      value: region,
                                      child: Text(region),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      context.read<CountryBloc>().add(
                                        FilterCountriesByRegionEvent(value)
                                      );
                                    }
                                  },
                                ),
                              ),
                              // Showing the countries list
                              state.isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: isLandscape
                                              ? screenHeight * 0.5
                                              : screenHeight * 0.6,
                                          child: GridView.builder(
                                            padding: const EdgeInsets.all(8.0),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: isLandscape ? 4 : 2,
                                              childAspectRatio:
                                                  isLandscape ? 1.5 : 1.0,
                                              crossAxisSpacing: 10,
                                              mainAxisSpacing: 10,
                                            ),
                                            itemCount:
                                                state.getPaginatedCountries().length,
                                            itemBuilder: (context, index) {
                                              final country =
                                                  state.getPaginatedCountries()[index];
                                              return CountryCard(
                                                country: country,
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CountryDetailScreen(
                                                              country: country),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        // Pagination controls
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.02,
                                            vertical: screenHeight * 0.01,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                onPressed: state.currentPage > 0
                                                    ? () {
                                                        context
                                                            .read<CountryBloc>()
                                                            .add(
                                                              ChangePaginationEvent(
                                                                  false),
                                                            );
                                                      }
                                                    : null,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                ),
                                                child: const Icon(Icons.arrow_back),
                                              ),
                                              const SizedBox(width: 20),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 20, vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  'Page ${state.currentPage + 1}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              ElevatedButton(
                                                onPressed: (state.currentPage + 1) *
                                                            state.itemsPerPage <
                                                        state.filteredCountries.length
                                                    ? () {
                                                        context
                                                            .read<CountryBloc>()
                                                            .add(
                                                              ChangePaginationEvent(
                                                                  true),
                                                            );
                                                      }
                                                    : null,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                ),
                                                child:
                                                    const Icon(Icons.arrow_forward),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SearchScreen(),
                  FavoritesPage(),
                ],
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.blue,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              currentIndex: state.currentIndex,
              onTap: (index) {
                context.read<CountryBloc>().add(ChangeBottomNavEvent(index));
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Favorites',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}