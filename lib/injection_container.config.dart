// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:elecciones/core/network/network_info.dart' as _i55;
import 'package:elecciones/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i26;
import 'package:elecciones/features/auth/data/repositories/auth_repository_impl.dart'
    as _i1056;
import 'package:elecciones/features/auth/domain/repositories/auth_repository.dart'
    as _i850;
import 'package:elecciones/features/auth/domain/usecases/get_current_user.dart'
    as _i249;
import 'package:elecciones/features/auth/domain/usecases/reset_password.dart'
    as _i583;
import 'package:elecciones/features/auth/domain/usecases/sign_in.dart' as _i681;
import 'package:elecciones/features/auth/domain/usecases/sign_out.dart'
    as _i138;
import 'package:elecciones/features/auth/domain/usecases/sign_up.dart' as _i591;
import 'package:elecciones/features/auth/presentation/bloc/auth_bloc.dart'
    as _i839;
import 'package:elecciones/features/provincial_dashboard/data/datasources/provincial_remote_data_source.dart'
    as _i395;
import 'package:elecciones/features/provincial_dashboard/data/repositories/provincial_repository_impl.dart'
    as _i920;
import 'package:elecciones/features/provincial_dashboard/domain/repositories/provincial_repository.dart'
    as _i860;
import 'package:elecciones/features/provincial_dashboard/domain/usecases/create_coordinador_usecase.dart'
    as _i1010;
import 'package:elecciones/features/provincial_dashboard/domain/usecases/create_recinto_usecase.dart'
    as _i880;
import 'package:elecciones/features/provincial_dashboard/domain/usecases/get_recintos_usecase.dart'
    as _i328;
import 'package:elecciones/features/provincial_dashboard/presentation/bloc/provincial_bloc.dart'
    as _i173;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i55.NetworkInfo>(
        () => _i55.NetworkInfoImpl(gh<_i895.Connectivity>()));
    gh.lazySingleton<_i395.ProvincialRemoteDataSource>(
        () => _i395.ProvincialRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i26.AuthRemoteDataSource>(
        () => _i26.AuthRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i850.AuthRepository>(() => _i1056.AuthRepositoryImpl(
          remoteDataSource: gh<_i26.AuthRemoteDataSource>(),
          networkInfo: gh<_i55.NetworkInfo>(),
        ));
    gh.factory<_i249.GetCurrentUser>(
        () => _i249.GetCurrentUser(gh<_i850.AuthRepository>()));
    gh.factory<_i583.ResetPassword>(
        () => _i583.ResetPassword(gh<_i850.AuthRepository>()));
    gh.factory<_i681.SignIn>(() => _i681.SignIn(gh<_i850.AuthRepository>()));
    gh.factory<_i138.SignOut>(() => _i138.SignOut(gh<_i850.AuthRepository>()));
    gh.factory<_i591.SignUp>(() => _i591.SignUp(gh<_i850.AuthRepository>()));
    gh.lazySingleton<_i860.ProvincialRepository>(() =>
        _i920.ProvincialRepositoryImpl(gh<_i395.ProvincialRemoteDataSource>()));
    gh.lazySingleton<_i1010.CreateCoordinadorUseCase>(() =>
        _i1010.CreateCoordinadorUseCase(gh<_i860.ProvincialRepository>()));
    gh.lazySingleton<_i880.CreateRecintoUseCase>(
        () => _i880.CreateRecintoUseCase(gh<_i860.ProvincialRepository>()));
    gh.lazySingleton<_i328.GetRecintosUseCase>(
        () => _i328.GetRecintosUseCase(gh<_i860.ProvincialRepository>()));
    gh.factory<_i839.AuthBloc>(() => _i839.AuthBloc(
          signIn: gh<_i681.SignIn>(),
          signUp: gh<_i591.SignUp>(),
          resetPassword: gh<_i583.ResetPassword>(),
          signOut: gh<_i138.SignOut>(),
          getCurrentUser: gh<_i249.GetCurrentUser>(),
        ));
    gh.factory<_i173.ProvincialBloc>(() => _i173.ProvincialBloc(
          getRecintos: gh<_i328.GetRecintosUseCase>(),
          createRecinto: gh<_i880.CreateRecintoUseCase>(),
          createCoordinador: gh<_i1010.CreateCoordinadorUseCase>(),
        ));
    return this;
  }
}
