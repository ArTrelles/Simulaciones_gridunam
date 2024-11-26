/* Programa que resuleve el problema de N-cuerpos */

// Este programa usa el esquema de integracion de 'Hamiltonian Spliting'
// dado por Pelupessy et al. 2012

// Este programa es como la version nbody_hamsp_old.c pero aqui se considera
// que las CIs estan en unidades fisicas.

// Para compilar: gcc nbody_hamsp.c -Wall -lm -o hs_fis


# include <stdio.h>
# include <math.h>
# include <stdlib.h>
#include <ctype.h>
#include <stdbool.h>
#include <time.h>

#include <string.h>

#include <omp.h>

// Valores de algunos parametros
//# define   N     131072			// Numero de particulas (debe coincidir con el numero de renglones del archivo de CIs)
# define Mt_fis  1.25e12		// Masa total del sistema en Msun (masas solares) 
# define Rt_fis  400.0			// Radio total del sisteema en kpc
# define rs_fis  15.0			// Radio de escala del sistema en kpc
# define c_NFW   26.67			// Parametro de concentracion, c, del modelo NFW
# define modelo  1				// Indica el modelo para el perfil de densidad: Plummer=0,NFW=1,Hernquist=2,corem=3
//# define eps_fis 1.5			// Softening en kpc
//# define Ntd_tf  0.01				// Numero de tiempos dinamicos a r=Rt que se evolucionara el sistema, i.e. tf=Ntd_tf*tdun(Rt)
# define Ftd_dt  5.0e-2			// Proporcion del paso de tiempo maximo que se tomara como el dt base, i.e. dt0=Ftd_dt*dtmax
# define eta1    5.5e-2			// Parametro que da la precision del paso de tiempo free-fall
# define eta2    5.5e-2			// Parametro que da la precision del paso de tiempo fly-by
# define rlodt   4				// Numero de niveles de refinamiento para los pasos de tiempo
# define cada    1				// Indica cada cuantos pasos de tiempo se guardara la energia del sistema
# define snp     4				// Numero de snapshots que se guardaran las coordenadas 

# define  pi   M_PI
# define G_ad  1.0				// Constante gravitacional (en unidades adimensionales)
# define G_fis 4.302e-6			// Constante gravitacional en kpc*Msun-1*(km/s)^2



// ----------------------------------------------------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------------------------------------------------- //
